## ADDED Requirements

### Requirement: Free-form question prompt (shared input)
The feature SHALL provide two commands, `:ResearchLocal` and `:ResearchAsk`, each of which prompts the user for a free-form question through a single shared input mechanism before issuing any request. Cancelling or submitting empty input SHALL abort with no request and no result window.

#### Scenario: Prompt for a question
- **WHEN** the user runs `:ResearchAsk` or `:ResearchLocal`
- **THEN** an input prompt appears for a free-form question

#### Scenario: Cancel or empty input aborts
- **WHEN** the user cancels the input prompt or submits an empty question
- **THEN** no `claude` call is made and no result window opens

### Requirement: General research via `:ResearchAsk`
`:ResearchAsk` SHALL send the user's question verbatim, with no configuration context, to the `claude` CLI (`claude -p`) and display the response in the shared floating window.

#### Scenario: General-knowledge question
- **WHEN** the user runs `:ResearchAsk` and asks a general-knowledge question (e.g. the directives of the Common Lisp `format` function)
- **THEN** the bare question is sent to `claude -p` and the answer is shown in a floating window

### Requirement: Local config-grounded research via `:ResearchLocal`
`:ResearchLocal` SHALL build a prompt that includes context about *this* Neovim configuration — the live keymap descriptions and the assembled cheatsheet content — and instruct the model to answer using only that context and to state when the answer is not present, then send it to `claude -p` and display the response in the shared floating window.

#### Scenario: Question answered from config context
- **WHEN** the user runs `:ResearchLocal` and asks "how do I toggle the terminal?"
- **THEN** the prompt includes the configuration's keymap descriptions
- **AND** the answer reflects the configuration's actual binding rather than generic Neovim advice

#### Scenario: Context reflects live keymaps
- **WHEN** the local-research prompt is assembled
- **THEN** it includes keymap descriptions read live from the running configuration (so an added or edited keymap is reflected without any documentation update)

#### Scenario: Question outside the context
- **WHEN** the user runs `:ResearchLocal` with a question not covered by the provided context
- **THEN** the model is instructed to state that it cannot find the answer in the configuration rather than fabricate a generic answer

### Requirement: Identical result presentation
Both commands SHALL display their results through the same shared floating-window helper (the helper also used by `claude-cli-integration`), with markdown filetype highlighting and `q` / `<Esc>` to dismiss. The result window's look and feel SHALL be identical across both commands.

#### Scenario: Same window for both paths
- **WHEN** `:ResearchLocal` and `:ResearchAsk` each return a result
- **THEN** both render in a floating window of the same dimensions, border, and dismissal keys

#### Scenario: Dismiss the result
- **WHEN** the result float is focused and the user presses `q` or `<Esc>`
- **THEN** the float closes and focus returns to the previous window

### Requirement: claude CLI availability and authentication
The commands SHALL rely on Claude Code's built-in authentication and SHALL NOT require an `ANTHROPIC_API_KEY`. When `claude` is not found on `$PATH`, the command SHALL emit a `vim.notify` error and abort without opening a window.

#### Scenario: claude CLI not installed
- **WHEN** `claude` is not on `$PATH` and the user runs `:ResearchLocal` or `:ResearchAsk`
- **THEN** a `vim.notify` error is emitted and no request is made and no window opens

#### Scenario: No API key required
- **WHEN** `claude` is authenticated via Claude Code and the user runs either command
- **THEN** the command succeeds without any `ANTHROPIC_API_KEY` being set

### Requirement: Asynchronous, non-blocking execution
The CLI call SHALL run asynchronously via `vim.system` so the editor remains responsive; an informational notification SHALL indicate the request is running, and the result SHALL be rendered on the main loop when it completes.

#### Scenario: Editor stays responsive while running
- **WHEN** a research command is running
- **THEN** the editor remains responsive and an informational "running" notification is shown
- **AND** the result is displayed in the float once the call completes

### Requirement: Keymap bindings
The feature SHALL bind `<leader>?l` to `:ResearchLocal` and `<leader>?a` to `:ResearchAsk` in Normal mode via `lua/keymaps.lua`, each with a `desc`, extending the existing `<leader>?` help namespace.

#### Scenario: Local research keymap
- **WHEN** the user presses `<leader>?l` in Normal mode
- **THEN** `:ResearchLocal` is triggered

#### Scenario: General research keymap
- **WHEN** the user presses `<leader>?a` in Normal mode
- **THEN** `:ResearchAsk` is triggered
