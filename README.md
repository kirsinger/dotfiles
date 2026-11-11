# dotfiles

Configuration for this machine, applied with nix-darwin and home-manager (`./rebuild.sh`). Project tasks run through mise: `global.mise.toml` is linked to `~/projects/mise.toml`, and each project has its own config under `~/projects/shared/`.

## Ticket workflow

Agent work starts from a ticket. A ticket is a markdown file describing one piece of work, which becomes one branch, one worktree, one Claude Code session and one PR.

### Layout

```
~/projects/
  knowledge/            planning repo, home of the planning session
    AGENTS.md           ticket format and authoring rules for the planner
    tickets/<repo>/     tickets, e.g. tickets/edrolo/0007_fix_sort.md
  tickets -> knowledge/tickets
  <repo>/               project checkouts
  worktrees/            one worktree per ticket branch
```

### Ticket format

```markdown
---
title: Fix markbook column sort order
status: TO_DO
priority: 2
jira: LLSB-1234
pr:
session:
---
## Context
## Scope
## Acceptance criteria
## Out of scope
```

| Field | Values | Set by |
|---|---|---|
| `status` | `TO_DO`, `IN_PROGRESS`, `DONE` | planner, `work_ticket`, `ticket_sync` |
| `priority` | `1` blocking, `2` required, `3` nice to have | planner |
| `jira` | Jira key, optional | planner |
| `pr` | PR URL | `ticket_sync` |
| `session` | Claude Code session UUID | `work_ticket` |

The frontmatter is parsed with awk, so every field must be a single `key: value` line with no comments.

The branch, worktree and herdr workspace share one name. If the ticket has a Jira key, the name is the lowercase key plus the slug (`llsb-1234-fix-sort`). Otherwise it is the filename (`0007-fix-sort`).

### Weekly loop

1. **Plan.** `mise run plan` opens (or reuses) the `knowledge` herdr workspace running a Claude session named `planning`. Write tickets with it. `knowledge/AGENTS.md` tells it where tickets go and what they contain.
2. **Review.** `mise run tickets` lists open tickets by status and priority. `--repo X` filters by repo and `--all` includes DONE tickets.
3. **Start work.** `mise run work_ticket` picks the next ticket: the highest priority `TO_DO`, lowest number first. You can name one instead: `work_ticket edrolo/0007`, `work_ticket 0007 --repo edrolo` or a file path. Each run:
   - creates the worktree in the ticket's repo,
   - opens a herdr workspace in the background (`--attach` switches to it),
   - starts `claude --session-id <uuid>` with a prompt pointing at the ticket,
   - sets the ticket to `IN_PROGRESS` and records the session ID.

   Run it several times to start several agents. It works from any directory.
4. **Follow up.** The agent stays within the ticket and writes a new `TO_DO` ticket when the work grows. It opens a PR when the acceptance criteria are met. Run `mise run ticket_sync` to record PR links and mark tickets with merged PRs `DONE`.
5. **Clean up.** `mise run clean_worktrees` (run inside a project) removes merged or stale worktrees and closes their herdr workspaces.

### Resuming

If a ticket is `IN_PROGRESS` and its workspace has been closed, `mise run work_ticket <ticket>` reopens the workspace and resumes the recorded session with `claude --resume`. If the workspace still exists, the task leaves it alone. Switch to it with `mise run dev <branch>`.

### Tasks

| Task | Purpose |
|---|---|
| `plan` | Open the planning session in `knowledge` |
| `tickets` | List tickets |
| `ticket_next` | Print the path of the next `TO_DO` ticket |
| `work_ticket` | Start or resume an agent on a ticket |
| `ticket_sync` | Fill in PR links and mark merged tickets `DONE` |
| `dev` | Open a herdr workspace for a checkout or worktree without starting an agent |
| `kill_agent` | Close the herdr workspace for a worktree |
| `clean_worktrees` | Remove merged or stale worktrees and their workspaces |
