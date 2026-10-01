## Context

Git in this config is vim-fugitive (`<leader>gs/gb/gl/gd/gp`), gitsigns (`]h`/`[h`, `<leader>h*`) and diffview (`<leader>gD/gH/gX`), all in `lua/plugins/git.lua`. Terminals are opened directly by config code, not through a plugin: `toggle_terminal` in `lua/keymaps.lua` uses `:term`, and `claudecode.nvim` uses its native provider. Floating scratch windows go through `util.open_float` in `lua/config/util.lua`.

Facts checked on 2026-10-01 that shape this design:

- `lazygit` is not installed on the WSL machine, and Ubuntu 24.04 has no `lazygit` apt package (`apt-cache policy lazygit` printed nothing).
- `lua/keymaps.lua:209` maps `<Esc>` in terminal mode to `<C-\><C-n>` for every terminal. LazyGit uses `<Esc>` to cancel and go back, so that map would eat it.
- `nvim` on this machine is a shell alias, not a binary on `$PATH`. Anything LazyGit runs through a shell cannot rely on `nvim` resolving.
- The colorscheme style is a local in `lua/plugins/colorscheme.lua` (currently `"moon"`); the active scheme name is visible at runtime as `vim.g.colors_name`.
- `<leader>gg` and `<leader>gf` are unbound.

LazyGit behaviour below (`LG_CONFIG_FILE`, `--print-config-dir`, `-f`, `os.edit*`, `gui.theme`) is from LazyGit's documentation and has not been exercised here, because LazyGit is not installed. Task 1 verifies it before any code depends on it.

## Goals / Non-Goals

**Goals:**

- One key opens LazyGit over the editor for the current buffer's repository; another opens it on the current file's history.
- Editing a file from LazyGit lands in the outer Neovim, not a nested instance.
- LazyGit's colours follow the active TokyoNight style.
- After LazyGit closes, buffers, gitsigns and nvim-tree reflect whatever LazyGit changed.
- The user's own LazyGit config keeps applying and is never written to.

**Non-Goals:**

- Replacing or changing fugitive, gitsigns or diffview.
- Containerising LazyGit.
- Installing LazyGit automatically.
- Keeping a LazyGit session alive while the float is hidden. Closing the float ends LazyGit; reopening starts it again.

## Decisions

### D1 — Own module, no plugin

`lua/config/lazygit.lua` exposes `setup()` (keymaps and `:LazyGit` / `:LazyGitFile` commands) and is wired from `init.lua` like `claude_cli` and `openspec`. It opens a float with `nvim_open_win` and starts LazyGit with `jobstart(cmd, { term = true, cwd = root, env = ..., on_exit = ... })`.

*Alternative:* `kdheepak/lazygit.nvim`. It provides the same commands, but it is another plugin to track for Neovim 0.12 API drift, and the parts this change needs to control (environment, `<Esc>` handling, refresh on close) would have to be configured around it anyway.

### D2 — Repository root from the buffer, then cwd

The job's `cwd` is `git rev-parse --show-toplevel` run from the current buffer's directory. If the buffer has no file or is not in a repository, the same lookup runs from Neovim's cwd. If neither is in a repository, a warning is shown and nothing opens. LazyGit's own "not a git repository" screen is not shown, because it offers to open unrelated recent repositories.

### D3 — Settings passed via `LG_CONFIG_FILE`, user config kept first

LazyGit reads `LG_CONFIG_FILE` as a comma-separated list of config files, merged in order, *instead of* its default `config.yml`. So the job's environment sets `LG_CONFIG_FILE` to `<user config>,<generated file>`, where `<user config>` is `<lazygit --print-config-dir>/config.yml` if it exists. The user's settings still apply; the generated file's keys win where they overlap. The variable is set only in the job's `env`, so a LazyGit started from a shell is unaffected.

*Alternative:* write into the user's `config.yml`. Rejected: it changes LazyGit outside Neovim and the user did not ask for that.

### D4 — Generated config file, not a static one in the repo

The settings depend on two runtime values: the path of the running Neovim binary (D5) and the active TokyoNight palette (D6). A static YAML in the repo can hold neither. So the module writes `stdpath("state")/lazygit/nvim.yml` on each launch and points `LG_CONFIG_FILE` at it. The generator lives in the repo, so the content is still repo-managed; only the output is machine-local.

*Alternative:* a static `lazygit/config.yml` with a hardcoded palette and the `nvim-remote` edit preset. Rejected because of the `nvim` alias (D5) and because the colours would go stale when `style` changes.

### D5 — `e` calls back into the outer Neovim by its own path

Inside a Neovim terminal job, `$NVIM` holds the parent's server address. The generated config sets `os.edit` and `os.editAtLine` to run the parent's own binary — passed as `LAZYGIT_NVIM_BIN=v:progpath` in the job's env — with `--server "$NVIM" --remote-expr` calling a function in this module, e.g. `v:lua.require'config.lazygit'.edit(<file>, <line>)`. That function schedules: close the float (which ends the job), go to the window that was current before the float opened, `:edit` the file, and jump to the line. `os.editInTerminal` is set to false so LazyGit does not wait on the call.

*Alternative:* LazyGit's built-in `editPreset: nvim-remote`. It calls `nvim` through a shell, which does not resolve here (alias), and it closes LazyGit by sending a `q` keystroke into the terminal, which depends on LazyGit's current panel.

### D6 — Theme from the TokyoNight palette at launch

The generator reads the palette for the active style (derived from `vim.g.colors_name`, e.g. `tokyonight-moon`) from TokyoNight's colors module and writes `gui.theme` entries: active and inactive border, selected line background, options text, cherry-picked commit colours, unstaged changes. If the colorscheme is not TokyoNight, or the palette cannot be loaded, the theme block is omitted and LazyGit's defaults apply. Under console mode (`config.terminal.is_console`, no truecolor), the theme block is also omitted.

### D7 — Float and keys

- Size: 90% of the editor's columns and lines, centred, rounded border, title ` LazyGit `. Resized on `VimResized` while open.
- A buffer-local terminal-mode `<Esc>` map sends `<Esc>` through to LazyGit, overriding the global `<Esc>` → normal-mode map for this buffer only. `q` is LazyGit's own quit key; no extra Neovim map.
- `<leader>gg` → repository; `<leader>gf` → `lazygit -f <path of current file relative to root>`. `<leader>gf` reads as *git file*. Both registered eagerly in `setup()` with `desc`, so which-key lists them.
- The buffer is wiped when the job exits (`bufhidden = wipe`), so no stale terminal buffers collect.

### D8 — Refresh on close

In the job's `on_exit`, scheduled:

1. `:checktime`, to reload buffers changed on disk.
2. gitsigns refresh, if gitsigns is loaded.
3. nvim-tree reload, if nvim-tree is loaded.

Each step is wrapped so a failure in one does not skip the others.

### D9 — LazyGit missing

If `lazygit` is not executable, `<leader>gg` and `<leader>gf` show an error naming the binary and pointing to `getting-started.adoc`, and open nothing.

## Risks / Trade-offs

- [LazyGit documentation differs from the installed version on `LG_CONFIG_FILE`, `--print-config-dir`, `-f` or `os.*` keys] → task 1 verifies each against the installed binary before implementation; design is amended if any differ.
- [`{{filename}}` quoting in `os.edit` breaks on paths with quotes or spaces] → test with a filename containing a space and one containing a single quote; if LazyGit does not quote safely, pass the path through an environment variable or escape in the generated template.
- [Closing the float from inside the `--remote-expr` call kills the process that is waiting for the call] → `edit()` only schedules the close and returns immediately; `os.editInTerminal: false` stops LazyGit from waiting.
- [Global `<Esc>` terminal map reapplied after the buffer-local one] → buffer-local maps take precedence over global ones; validated by a test step.
- [The generated file is rewritten on every launch] → it is small and rewritten whole; no concurrency between launches in one Neovim.
- [mosh/remote sessions: `$NVIM` socket path] → the job is a child of the same Neovim, so the socket is local to that host; no change expected, covered by one remote-session test step when that host is available.

## Migration Plan

Additive. Rollback is removing the `setup()` call from `init.lua` and the module. `lazygit` stays installed on the host harmlessly.

## Open Questions

None blocking. Task 1 confirms the LazyGit facts marked as unverified above.
