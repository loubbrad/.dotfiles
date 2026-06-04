---
name: Send to Quickfix List
description: Use when the user asks to send jumpable code locations to Neovim quickfix/qfl, or asks to show, list, surface, collect, or navigate code locations. Do not use for ordinary explanations, edits, reviews, searches, tests, summaries, diffs, or command output unless the user explicitly asks for qfl/quickfix or navigable locations.
---

# qfl

Use this skill to send requested file locations to the Neovim quickfix list in the current tmux session.

## Commands

Do not read the script for normal use; use this interface:

- `nvim -l "$HOME/.codex/skills/qfl/scripts/qfl.lua" write < entries.ndjson`
  Moves to the newest quickfix stack position, then creates a new quickfix history entry silently.
- `nvim -l "$HOME/.codex/skills/qfl/scripts/qfl.lua" write --modify-prev=N < entries.ndjson`
  Moves to the newest quickfix stack position, then replaces the list `N` steps back from newest. `N=0` means replace the newest list, `N=1` means replace the list before newest.
- `nvim -l "$HOME/.codex/skills/qfl/scripts/qfl.lua" read --prev=N`
  Returns JSON for the list `N` steps back. Use this sparingly for diagnostics.

Each stdin line for `write` is one JSON quickfix object. Prefer absolute `filename`, plus `lnum`, `col`, `text`, and optional `type`.

`server` and `read` print compact JSON. Successful `write` commands print nothing; failed writes print JSON with `ok:false` and a small `error` string. Looking too far back reports total/current history.

## Behavior

- Rely on the documented commands; do not inspect the script or call `read` on startup.
- Use only when the user asks for qfl/quickfix or when the requested output is primarily jumpable code locations; otherwise answer in chat.
- Skip incidental context files, purely conceptual discussion, and path mentions used only for attribution.
- Prefer 3-8 high-signal entries over exhaustive references.
- Create a new history entry by default. Use `--modify-prev=N` only when deliberately revising an existing quickfix list; `N` is always relative to newest.
- Neovim only keeps up to `'chistory'` quickfix lists, so the oldest lists may be dropped when that limit is reached.
- Do not open the quickfix window.
- Order entries to match the response's reasoning/order. For search/navigation-only tasks, natural file/line order is fine.
- Never mention successful quickfix updates in chat.
- Do not use sudo; this is expected to work for Neovim processes owned by the same user.
- Scope socket discovery to the current tmux session with `tmux list-panes -s`.
