## Context

`lua/config/terminal.lua` already owns environment detection for this config. Two of its flags are derived from the environment rather than from the terminal's identity: `is_wsl` (from `$WSL_DISTRO_NAME`) and `is_console` (from the absence of `$DISPLAY` and `$WAYLAND_DISPLAY`). `lua/options.lua` requires the module early and branches on those flags to pick a clipboard provider. `CLAUDE.md` states the convention directly: branch on `terminal.lua`'s flags rather than hardcoding terminal-specific behaviour.

What is missing is any notion of *remoteness*. `is_console` is the closest thing and it answers a different question — a headless server reads as console whether you are sitting at it or three hops away, and a WSLg session reads as non-console while still being local. `recommendations/ideas.md` records this as a known defect in its own right ("`is_console` answers the wrong question"), and issue #191 exists to fix the capability model wholesale.

Two consumers want remoteness now. lualine repaints on a 1000 ms timer whose output has to cross the link (#187), and `ttimeoutlen` sits at Neovim's 50 ms default, inside which a multi-byte escape sequence can be split by a jittery connection (#188).

Grounding all three issues against the code produced four facts that shape this design, all verified on 2026-09-10:

1. `timeout` and `ttimeout` are already `1` in the live config. Only `ttimeoutlen` is unset.
2. lualine's default `refresh.events` includes `CursorMoved`, `CursorMovedI` and `ModeChanged`, so the timer is an idle fallback, not the main driver of repaints.
3. Neither `User GitSignsUpdate` nor `DiagnosticChanged` is in that list, so the two components that read asynchronously-arriving state depend on the timer to notice it.
4. `SSH_CONNECTION` is in tmux's default `update-environment` (tmux 3.4), and `tmux show-environment SSH_CONNECTION` prefixes a `-` when tmux knows the variable to be unset — so "unset" and "no answer" are distinguishable.

## Goals / Non-Goals

**Goals:**

- One place that decides whether the session is remote, which other modules read rather than re-deriving.
- A flag that is correct in the setup #190 will recommend (tmux for session persistence), not merely correct for plain SSH.
- Adapt `ttimeoutlen` and lualine's repaint interval without degrading either locally.
- Leave the statusline's *content* as accurate as it is today; a longer repaint interval must not be paid for in stale counts.

**Non-Goals:**

- Reworking `detect()`, the terminal-name table, or the `has_nerd_font`/`has_undercurl`/`has_truecolor` lists. That is #191, it is architectural, and it reaches 10 require sites and 23 flag uses.
- Changing `is_console` or anything that reads it.
- Documenting the terminal-side setup for working at distance, or tmux configuration. That is #190.
- Port forwarding for preview servers. That is #192.
- Any behaviour beyond the two consumers named — no browser-versus-clipboard policy, no filesystem-walk changes, however plausible those are as future readers of the flag.

## Decisions

### D1 — The flag lives on `terminal.lua`, not in `vim.g`

`M.is_remote` joins `is_wsl` and `is_console` in `lua/config/terminal.lua`. Consumers `require("config.terminal")`.

Issue #189 proposes `global.is_remote` in `lua/options.lua` instead. Rejected: it would split environment detection across two files, and `CLAUDE.md` names `terminal.lua` as the place to branch from. The two existing environment-derived flags are already there, and #191 will need this one there when it reworks the capability model.

*Alternative considered — detect in `terminal.lua` and mirror to `vim.g.is_remote` in `options.lua`.* Rejected: it satisfies both records at the cost of two names for one fact, and nothing in the config needs the flag from a context where a `require` is unavailable.

### D2 — Resolve the tmux gap by asking the tmux server, rather than documenting it

Detection is, in order: `$SSH_TTY` or `$SSH_CONNECTION` present → remote. Otherwise, if `$TMUX` is set and `tmux` is executable, ask `tmux show-environment SSH_CONNECTION` and treat a value without the `-` prefix as remote. Otherwise local.

The gap being closed: environment variables are copied into a process at start and never updated, and tmux cannot update panes that already exist. A tmux session started before the SSH connection — or started locally and later attached to over SSH — therefore hosts a Neovim whose `$SSH_CONNECTION` is stale or absent, and which would read as local while being remote. That is precisely the configuration #190 will recommend, so the naive check is wrong in the case that matters most.

Issue #189 proposes accepting this with a comment. Rejected: `recommendations/ideas.md` is right that a flag which is wrong in some genuinely remote sessions is worse than no flag, because #187 and #188 are built on it and would then apply unpredictably. The cost is one subprocess, only inside tmux, and only when the environment variables are absent.

Only the *presence* of a value is tested, never its content, so a stale `SSH_CONNECTION` string from an earlier connection is harmless.

*Alternative considered — lazy evaluation behind `M.is_remote()`.* Rejected: both consumers read the flag during startup (`options.lua` at load, lualine at `VeryLazy`), so deferring buys nothing while making the API a call rather than a field, inconsistent with its two neighbours.

### D3 — `ttimeoutlen` is conditional, not the unconditional 100 ms that #188 asks for

`100` when remote, `50` when local, both written explicitly.

#188 names the trade-off itself: "higher values make leaving insert mode feel sluggish, so this is a trade rather than a free win." Having `is_remote` removes the trade entirely — the tolerance is only needed where the jitter is. Writing both branches rather than leaving the local case implicit records the value and prevents a future Neovim default change from silently altering local feel.

*Alternative considered — unconditional 100 ms as specified.* Rejected: it pays a permanent, felt local cost to fix a remote-only problem, when the enabling flag is landing in the same change. Worth noting this is a deviation from the issue as written, and the reason it is safe to deviate is that the bundle makes it so.

### D4 — Extend `refresh.events`; do not accept stale counts

`User GitSignsUpdate` and `DiagnosticChanged` are added to lualine's `refresh.events`.

Without this, #187 trades an idle-traffic win for a correctness regression. The gitsigns `diff` source reads `vim.b.gitsigns_status_dict` and the `diagnostics` component reads `vim.diagnostic`; both are populated asynchronously, after the debounce or after the language server replies — which is after the last `CursorMoved`. At 1000 ms the lag is invisible. At 5000 ms it is up to five seconds of visibly wrong hunk and error counts while the buffer sits idle, which is exactly when someone is reading the statusline.

Adding the two events makes both components event-driven, so the timer interval stops mattering for their correctness. It cannot increase repaint frequency beyond the status quo, because `CursorMovedI` is already in the list and fires far more often than either new event.

*Alternative considered — a smaller interval such as 2000 ms.* Rejected as a half measure: it shortens the staleness window without closing it, and gives up most of the idle-traffic saving.

**Implementation trap, verified in lualine's source.** `refresh` is the one option lualine deep-merges rather than replaces (`lualine/config.lua:127`), using `vim.tbl_deep_extend('force', ...)`. Because `events` is a list, that merge is index-wise: supplying a two-entry list overwrites entries 1 and 2 and retains defaults 3 through 10, which would drop `WinEnter` and `BufEnter` while looking like it worked. All ten defaults must therefore be restated ahead of the two additions, and the resolved list must be checked at runtime rather than read off the config file.

### D5 — Scope boundary against #191

This change adds a flag and two consumers. It does not touch `detect()`, the name table, or the capability lists, even though `is_remote` is the fact #191 needs. Keeping the boundary sharp means a misbehaviour after this lands is attributable to three small diffs rather than to a rewrite of the module.

## Risks / Trade-offs

**`<Esc>` feels slower on remote sessions.** → Inherent to #188 and now confined to remote sessions by D3. Needs a live feel-test rather than a headless check; if 100 ms is intolerable, 75 ms is the fallback. Local behaviour is unchanged by construction.

**The tmux query adds startup latency inside tmux.** → One `vim.fn.system` call, guarded by `$TMUX` and `executable("tmux")`, reached only when both SSH variables are absent. Plain SSH never reaches it; a local session outside tmux never reaches it. Measure it during validation and record the number.

**`DiagnosticChanged` could increase remote repaints while typing.** → It cannot exceed the status quo: `CursorMovedI` is already in the default event list, so any keystroke already triggers a refresh. The new event adds refreshes only in the idle-after-typing window, which is the case it exists to fix.

**`has_truecolor` can report true while tmux downsamples colour.** → Pre-existing and out of scope here, but it will bite anyone following #190's advice, because the flag is derived from the terminal *name* and not from what tmux passes through. Recorded in `recommendations/ideas.md`; #190 must ship `default-terminal` and `terminal-overrides ",*:Tc"` alongside its tmux recommendation.

**A future reader assumes `is_remote` implies `is_console`, or the reverse.** → They are independent by design and this is the confusion #191 exists to resolve. The spec states the independence explicitly, and the code comment names both.

## Open Questions

- **Does mosh set `SSH_CONNECTION`?** #190 mentions mosh as an option for high-latency links. If it does not, `is_remote` will read false under mosh and the tmux fallback will not help unless mosh is used with tmux. Unverified — mosh is not installed here. Resolve before #190 recommends mosh, not before this change lands.
- **Is 5000 ms the right remote interval?** Chosen because #187 proposes it. Nothing was measured against 3000 ms. Settle during validation on a real link rather than by argument.
