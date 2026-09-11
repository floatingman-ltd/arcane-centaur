## ADDED Requirements

### Requirement: terraformls is configured as the Terraform LSP server
The config SHALL register `terraformls` via the native `vim.lsp.config`/`vim.lsp.enable` API using the shared `on_attach` and `capabilities` defined in `lua/config/lsp.lua`, providing diagnostics, hover documentation, go-to-definition, references, completion and document symbols in Terraform buffers.

#### Scenario: LSP attaches on Terraform buffer open
- **WHEN** the user opens a `.tf` file and `terraform-ls` is on `$PATH`
- **THEN** `terraformls` SHALL attach to the buffer
- **AND** the keymaps registered by the shared `on_attach` SHALL be active

#### Scenario: Keymaps match other languages
- **WHEN** `terraformls` attaches to a Terraform buffer
- **THEN** all keymaps SHALL be identical to those registered for `fsautocomplete`, `marksman` and `lua_ls`

#### Scenario: Missing binary does not crash
- **WHEN** `terraform-ls` is not installed or not on `$PATH`
- **THEN** Neovim SHALL start without error and no LSP SHALL attach to Terraform buffers

### Requirement: The server's dependence on the terraform CLI is recorded
`terraformls` resolves much of what it answers by invoking the `terraform` binary. The documentation SHALL state that the CLI is a prerequisite of the server and not only of the formatter, so that a session with the server installed but the CLI absent is recognisable rather than mysterious.

#### Scenario: Server present, CLI absent
- **WHEN** `terraform-ls` is on `$PATH` but `terraform` is not
- **THEN** the documentation SHALL describe which capabilities degrade
- **AND** Neovim SHALL NOT fail to start
