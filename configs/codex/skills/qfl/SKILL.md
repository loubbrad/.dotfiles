---
name: Send to Quickfix List
description: Use during coding sessions whenever Codex produces or discovers concrete file locations that the user may want to inspect in their code editor (Neovim), including diagnostics, review findings, bugs, search results, TODO followups, or implementation touchpoints. Populate the current tmux session's Neovim quickfix list quietly and proactively.
---

# qfl

Use this skill to send useful file locations to the Neovim quickfix list in the current tmux session.

## Commands

Do not read the script for normal use; use this interface:

- `nvim -l "$HOME/.codex/skills/qfl/scripts/qfl.lua" write < entries.ndjson`
  Creates a new quickfix history entry silently.
- `nvim -l "$HOME/.codex/skills/qfl/scripts/qfl.lua" write --modify-prev=N < entries.ndjson`
  Overwrites the list `N` steps back in quickfix history. `N=0` means current, `N=1` means previous.
- `nvim -l "$HOME/.codex/skills/qfl/scripts/qfl.lua" read --prev=N`
  Returns JSON for the list `N` steps back. Use this sparingly for diagnostics.

Each stdin line for `write` is one JSON quickfix object. Prefer absolute `filename`, plus `lnum`, `col`, `text`, and optional `type`.

All commands print compact JSON. Check `ok`; failures use `ok:false` and a small `error` string. Looking too far back reports total/current history.

## Behavior

- Rely on the documented commands; do not inspect the script or call `read` on startup.
- Use proactively when concrete file locations would help, unless the user is only discussing design.
- Create a new history entry by default. Use `--modify-prev=N` only when revising an existing quickfix list.
- Do not open the quickfix window.
- Order entries to match the response's reasoning/order. For search/navigation-only tasks, natural file/line order is fine.
- Keep chat notes tiny and avoid duplicating quickfix contents.
- Do not use sudo; this is expected to work for Neovim processes owned by the same user.
- Scope socket discovery to the current tmux session with `tmux list-panes -s`.
