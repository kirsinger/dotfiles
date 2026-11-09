---
name: tidy
description: Review stale and merged worktrees of the current project and remove the ones the user picks.
argument-hint: "[--days N]"
disable-model-invocation: true
---

Tidy the current project's worktrees.

1. Run `mise run clean_worktrees --list $ARGUMENTS`. It prints a JSON array of flagged worktrees, each with `name`, `branch`, `reasons`, `merged` and `dirty`.
2. If it's empty, say so and stop.
3. Show a table: name, branch, reasons, and what removal does. Merged worktrees lose the worktree and the branch. Unmerged ones lose only the worktree. Dirty worktrees also lose their uncommitted changes. Group the merged and clean ones as the proposed set. List the dirty and unmerged ones separately as kept unless the user says otherwise. For a dirty worktree, show `git -C <path> status --short` so the user can see what would be lost.
4. Ask which to remove, and wait for an explicit answer.
5. Run `mise run clean_worktrees --remove <comma-separated names>` with exactly the confirmed names, and report the output.
