#!/bin/sh
# SessionStart/CwdChanged hook: applies the mise env of the session's directory to Claude's
# Bash commands, minus secrets. `mise activate` only runs from a prompt hook, so without this
# Bash keeps whatever env the launching shell had (e.g. the main checkout's venv).
set -u
INPUT=$(cat)
[ -n "${CLAUDE_ENV_FILE:-}" ] || exit 0
DIR=$(printf '%s' "$INPUT" | jq -r '.new_cwd // .cwd // empty')
[ -n "$DIR" ] && [ -d "$DIR" ] || exit 0

TOP=$(git -C "$DIR" rev-parse --show-toplevel 2>/dev/null) || TOP=
case "$DIR" in
  "$HOME"/projects/*)
    COMMON=$(git -C "$DIR" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || COMMON=
    if [ -n "$TOP" ] && [ -n "$COMMON" ]; then
      mise -C "$HOME/projects" run -q link_project_config "$(dirname "$COMMON")" "$TOP" >&2 || true
    fi
    ;;
esac

# hook-env diffs against the inherited __MISE_DIFF, so it also undoes the launching
# shell's project env (venv, PATH) when that was a different checkout.
ENV=$(cd "$DIR" && mise hook-env -s bash -f 2>/dev/null) || exit 0
NAMES=$("$(dirname "$0")/../bin/secret-names") || exit 0
# __MISE_DIFF/__MISE_SESSION encode the full env, secrets included.
SECRETS="$NAMES __MISE_DIFF __MISE_SESSION"
{
  printf '%s\n' "$ENV" | awk -v names="$(echo $SECRETS)" '
    BEGIN { n = split(names, a, " "); for (i = 1; i <= n; i++) secret[a[i]] = 1 }
    /^export / { name = $2; sub(/=.*/, "", name); if (name in secret) next }
    { print }
  '
  for name in $SECRETS; do echo "unset $name"; done
} >> "$CLAUDE_ENV_FILE"

VENV=$(bash -c 'eval "$1" >/dev/null 2>&1; printf %s "${VIRTUAL_ENV:-}"' _ "$ENV")
if [ -n "$VENV" ] && [ -n "$TOP" ] && [ -f "$TOP/pyproject.toml" ]; then
  # A venv mise has just created holds only pip/setuptools-level packages.
  COUNT=$(ls -d "$VENV"/lib/python*/site-packages/*.dist-info 2>/dev/null | wc -l | tr -d ' ')
  if [ "$COUNT" -lt 5 ]; then
    echo "This checkout's virtualenv ($VENV) has no project packages installed. Run \`mise run sync_venv\` before running Python here."
  fi
fi
exit 0
