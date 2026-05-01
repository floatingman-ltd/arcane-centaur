## 1. Console Detection

- [x] 1.1 Add `M.is_console` boolean to `lua/config/terminal.lua` — `true` when both `$DISPLAY` and `$WAYLAND_DISPLAY` are unset
- [x] 1.2 Verify `M.is_console` is `false` when either env var is set (covers GUI X11, Wayland, and tmux-inside-GUI cases)

## 2. Markdown Preview

- [x] 2.1 Add `glow.nvim` to `lua/plugins/markdown.lua` with `cond = function() return require("config.terminal").is_console end`
- [x] 2.2 Wrap the existing `markdown-preview.nvim` spec with the inverse `cond` so exactly one preview plugin loads per session
- [x] 2.3 Add a `glow` binary check that emits a `WARN` notification with install instructions when `glow` is not on `$PATH`
- [x] 2.4 Route the shared preview keymap to `:Glow` in console and `:MarkdownPreview` in GUI so the trigger is consistent

## 3. PlantUML ASCII

- [x] 3.1 Implement `puml_preview_ascii()` in the existing PlantUML config — encode the diagram, hit the `/utxt/` endpoint via `curl`, write output to a `buftype=nofile` scratch buffer in a vertical split
- [x] 3.2 Register `:PumlPreviewAscii` for the `plantuml` filetype in all environments
- [x] 3.3 Route `:PumlPreview` to `puml_preview_ascii()` when `is_console`; keep the existing PNG path for GUI
- [x] 3.4 Emit an `ERROR` notification and abort if URL encoding fails; do not open the scratch buffer

## 4. Open URL

- [x] 4.1 Add a console branch to `open_url()` in `lua/config/util.lua` (or wherever it lives) that emits an `INFO` notification with the full URL and returns early, skipping all opener attempts
- [x] 4.2 Confirm the existing GUI `WARN` path (no opener found) is untouched

## 5. Avante AI Research

- [x] 5.1 Create `lua/plugins/avante.lua` with `avante.nvim` spec, configuring `ollama` as the default provider (`http://127.0.0.1:11434`, model `llama3.1:8b`)
- [x] 5.2 Add `copilot` as a secondary provider, reusing the existing `github/copilot.vim` auth — no additional token required
- [x] 5.3 Add `<leader>aa` keymap — opens avante without changing the active provider
- [x] 5.4 Add `<leader>ao` keymap — switches to ollama provider and opens avante
- [x] 5.5 Add `<leader>ac` keymap — switches to copilot provider and opens avante
- [x] 5.6 Confirm avante surfaces an error in its buffer when ollama is unreachable; Neovim must not crash

## 6. Ollama Docker Service

- [x] 6.1 Create `docker/ollama/docker-compose.yml` with `ollama/ollama` image, loopback-only port binding `127.0.0.1:11434:11434`, named volume for `/root/.ollama`, and `restart: unless-stopped`
- [x] 6.2 Add commented-out NVIDIA GPU annotations so GPU opt-in is documented but not active by default
- [x] 6.3 Verify `docker compose config` exits 0 for the new file

## 7. Documentation

- [x] 7.1 Create `docs/guides/cli-console-mode.md` covering: how `is_console` is detected, glow setup, PlantUML ASCII usage, ollama Docker setup (`docker compose up -d`), avante keymaps, and `open_url` behaviour
- [x] 7.2 Update `readme.md` to list the new `<leader>aa/ao/ac` keymaps and note the console-mode feature

## 8. Validation

- [x] 8.1 Syntax-check all modified Lua files with `luac -p`
- [x] 8.2 Start Neovim with `DISPLAY` unset and confirm `term.is_console` is `true` and `:Glow` is available

  **Precondition:** `glow` binary is installed (`which glow` returns a path).

  ```sh
  # Launch Neovim with no graphical display variables set.
  # If you are currently in a GUI session, unset them for this shell only.
  env -u DISPLAY -u WAYLAND_DISPLAY nvim /tmp/test.md
  ```

  Inside Neovim:

  1. Confirm the flag is `true`:
     ```
     :lua print(require("config.terminal").is_console)
     ```
     **Expected:** `true`

  2. Confirm `glow.nvim` loaded and `markdown-preview.nvim` did not:
     ```
     :lua print(require("lazy").plugins()["glow.nvim"] ~= nil)
     :lua print(require("lazy").plugins()["markdown-preview.nvim"] ~= nil)
     ```
     **Expected:** `true`, then `false`

     Or check via `:Lazy` — `glow.nvim` should show `loaded`, `markdown-preview.nvim` should show `not loaded` / `skipped`.

  3. Add content and invoke the preview keymap:
     ```
     i# Hello
     This is **bold** text.
     <Esc>
     ,p
     ```
     **Expected:** a vertical split opens with glow-rendered Markdown. No browser window opens.

  4. Confirm `:Glow` command exists:
     ```
     :Glow
     ```
     **Expected:** glow renders in a split (or re-uses the existing one).

- [x] 8.3 Start Neovim normally and confirm `term.is_console` is `false` and `:MarkdownPreview` is available

  **Precondition:** running in a normal GUI session where `$DISPLAY` or `$WAYLAND_DISPLAY` is set.

  ```sh
  nvim /tmp/test.md
  ```

  Inside Neovim:

  1. Confirm the flag is `false`:
     ```
     :lua print(require("config.terminal").is_console)
     ```
     **Expected:** `false`

  2. Confirm `markdown-preview.nvim` loaded and `glow.nvim` did not:
     ```
     :Lazy
     ```
     **Expected:** `markdown-preview.nvim` loaded, `glow.nvim` not loaded / skipped.

  3. Invoke the preview keymap:
     ```
     i# Hello
     <Esc>
     ,p
     ```
     **Expected:** a browser tab opens with the rendered Markdown. No split is opened in Neovim.

  4. Confirm `:MarkdownPreviewToggle` exists and `:Glow` does not:
     ```
     :MarkdownPreviewToggle
     :Glow
     ```
     **Expected:** first command succeeds; second emits `E492: Not an editor command: Glow`.

- [x] 8.4 Confirm `:PumlPreviewAscii` opens a scratch buffer with ASCII art in both modes

  **Precondition:** PlantUML Docker server is running.

  ```sh
  docker compose -f ~/.config/nvim/docker/plantuml-server/docker-compose.yml up -d
  # Verify it's up:
  curl -s http://localhost:8080/png/ | head -c 20
  ```

  Run the following steps in **both** console mode (`env -u DISPLAY -u WAYLAND_DISPLAY nvim`) and GUI mode (`nvim`):

  1. Open a `.puml` file:
     ```
     :e /tmp/test.puml
     ```

  2. Paste a minimal diagram:
     ```
     @startuml
     Alice -> Bob: Hello
     @enduml
     ```

  3. Run the command:
     ```
     :PumlPreviewAscii
     ```
     **Expected:**
     - A vertical split opens to the right.
     - The buffer contains Unicode box-drawing art (lines like `┌──────────────────────┐`).
     - `:set buftype?` in the new split shows `buftype=nofile`.
     - Closing the split with `:q` does **not** prompt "save changes?".

- [x] 8.5 Confirm `:PumlPreview` routes to ASCII in console mode and PNG in GUI mode

  Uses the same `/tmp/test.puml` from 8.4. PlantUML server must still be running.

  **Console mode** (`env -u DISPLAY -u WAYLAND_DISPLAY nvim /tmp/test.puml`):

  1. Run:
     ```
     :PumlPreview
     ```
     **Expected:** Unicode art appears in a vertical split scratch buffer. No browser is launched, no `open_url` notification is emitted.

  2. Verify the localleader keymap also routes correctly:
     ```
     ,p
     ```
     **Expected:** same scratch buffer result.

  **GUI mode** (`nvim /tmp/test.puml`):

  1. Run:
     ```
     :PumlPreview
     ```
     **Expected:** a browser window or tab opens with the PNG diagram. No split is opened in Neovim.

  2. Confirm the ASCII path is still reachable in GUI mode:
     ```
     :PumlPreviewAscii
     ```
     **Expected:** scratch buffer with ASCII art opens in a vertical split.

- [x] 8.6 Run `docker compose config` in `docker/ollama/` and confirm it exits 0
- [ ] 8.7 Confirm `<leader>aa`, `<leader>ao`, and `<leader>ac` are registered and open avante

  **Precondition:** avante.nvim is installed. On first launch after adding `lua/plugins/avante.lua`, run `:Lazy sync` and wait for it to complete.

  ```sh
  nvim
  ```

  **Verify the keymaps are registered:**

  ```
  :lua print(vim.fn.maparg("<leader>aa", "n") ~= "")
  :lua print(vim.fn.maparg("<leader>ao", "n") ~= "")
  :lua print(vim.fn.maparg("<leader>ac", "n") ~= "")
  ```
  **Expected:** all three print `true`.

  **Test `<leader>aa` — open with current provider:**

  1. Press `<leader>aa`.
     **Expected:** avante's chat panel opens with provider set to `ollama` (the default).
  2. Close with `:q` or the avante close keymap.

  **Test `<leader>ao` — switch to ollama and open:**

  1. Ensure the ollama Docker service is running and a model is pulled:
     ```sh
     docker compose -f ~/.config/nvim/docker/ollama/docker-compose.yml up -d
     docker compose -f ~/.config/nvim/docker/ollama/docker-compose.yml exec ollama ollama pull llama3.1:8b
     ```
  2. Press `<leader>ao`.
     **Expected:** avante opens with provider set to `ollama`.
  3. Type a short question (e.g. `What is 2+2?`) and submit.
     **Expected:** a response appears in the avante buffer. No Neovim crash.

  **Test `<leader>ao` with ollama unreachable (task 5.6 — Neovim must not crash):**

  1. Stop the ollama service:
     ```sh
     docker compose -f ~/.config/nvim/docker/ollama/docker-compose.yml stop
     ```
  2. Press `<leader>ao`, type a question, and submit.
     **Expected:** an HTTP connection error appears **inside the avante buffer**. Neovim remains functional.
  3. Restart the service when done:
     ```sh
     docker compose -f ~/.config/nvim/docker/ollama/docker-compose.yml start
     ```

  **Test `<leader>ac` — switch to copilot and open:**

  1. Confirm Copilot is authenticated:
     ```
     :Copilot status
     ```
     **Expected:** `Copilot: Enabled`. If not, run `:Copilot setup` first.
  2. Press `<leader>ac`.
     **Expected:** avante opens with provider set to `copilot`. No separate login prompt appears.
  3. Type a question and submit.
     **Expected:** a Copilot response appears in the avante buffer.
