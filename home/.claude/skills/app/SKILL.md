---
name: app
description: Start the Edrolo app stack for a worktree and report whether each service came up cleanly.
argument-hint: "[worktree]"
disable-model-invocation: true
---

Start the Edrolo app stack and check it.

1. Run `mise run start_edrolo $ARGUMENTS`. With no argument it uses the main checkout.
2. Poll `mise run edrolo_logs <service> --lines 60` for django, vite and react every ~5 seconds, for up to 2 minutes. A service is up when django prints "Starting development server" and vite/react print their local URL. Stop waiting on a service as soon as it shows a traceback, a build error or a port-in-use error.
3. Report each service's state on one line, with its URL or the error excerpt. For errors, read the relevant code before suggesting a fix. Point out an empty venv (ModuleNotFoundError) as `mise run sync_venv`, and missing node packages as `mise run sync_node`.

Don't stop the stack afterwards. The user attaches with `herdr session attach edrolo-app`.
