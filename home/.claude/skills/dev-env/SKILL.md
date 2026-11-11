---
name: dev-env
description: How to run, inspect and maintain Kai's local dev environment through mise tasks — starting/stopping the Edrolo app stack and reading its logs, creating/listing/cleaning git worktrees, syncing a checkout's Python venv or node_modules, the dev DB tunnel, AWS SSO and Fargate shells. Use when you need to run the Edrolo app to check a change, read runserver/vite/react output, deal with a missing or empty .venv or missing packages, manage worktrees, or hit expired AWS credentials.
---

# Dev environment tasks

Tasks are defined in `~/projects/mise.toml` (all projects) and `~/projects/shared/edrolo.mise.toml` (Edrolo checkouts). Run them with `mise run <task>` from inside the project. `mise tasks ls` lists what applies to the current directory.

Each checkout has its own `.venv`, and a SessionStart hook applies the checkout's mise env to your Bash commands. Secrets (API keys) are deliberately absent from your env. Tasks and `mise exec -- <cmd>` still receive them, so don't try to read or export them.

## Running the Edrolo app

- `mise run start_edrolo [worktree]` starts docker (lazydocker), django runserver, vite and react, as tabs in the `edrolo-app` herdr session. With no argument it uses the main checkout. The ports are fixed, so starting one checkout's stack replaces whichever was running.
- `mise run edrolo_logs <docker|django|vite|react> [--lines N]` prints a service's recent terminal output. Use it to wait for startup and to find tracebacks or build errors after a change.
- `mise run stop_edrolo` stops the stack.
- Each service prints its URL at startup; read it from `edrolo_logs`.

## Dependencies

- `mise run sync_venv` creates the checkout's `.venv` if needed and syncs it from `uv.lock`. Run it when the session-start note says the venv is empty, when imports fail with ModuleNotFoundError, or after `uv.lock` changes.
- `mise run sync_node` runs pnpm install for the frontend and yarn install for react. Note that react's `node_modules` is shared across checkouts.

## Worktrees

- `mise run list_worktrees`
- `mise run add_worktree <branch>` creates the worktree under `~/projects/worktrees/` and runs the project's `worktree_setup`.
- `mise run clean_worktrees --list` prints stale (unused > 14 days) and merged worktrees as JSON. `--remove a,b` removes named ones, which needs the user's approval. Prefer the `/tidy` flow.
- `mise run remove_worktree <name>` needs approval.

## Tickets

Tickets live in `~/projects/knowledge/tickets/<repo>/` (`~/projects/tickets` links there). `knowledge/AGENTS.md` describes the format.

- `mise run tickets [--repo X] [--all]` lists open tickets by status and priority. `--all` includes DONE.
- `mise run ticket_next [--repo X]` prints the path of the highest-priority TO_DO ticket.
- `mise run work_ticket [ticket]` and `mise run ticket_sync` start agents and change ticket fields. Leave them to the user.

## Hand these to the user

These need a browser, a long-lived terminal or production access. Ask the user to run them as `! mise run <task>`:

- `aws_sso`: when AWS calls fail with expired or missing SSO credentials.
- `db_tunnel`: a long-running SSH tunnel to a dev DB on port 3333. It writes the stack's current DB password to the pgpass file at `$PGPASSFILE`, so Django and `psql -h localhost -p 3333 edrolo` connect without a password.
- `fargate_shell <env> <service>`: an interactive shell in a Fargate task. Never target production yourself.
