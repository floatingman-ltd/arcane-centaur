## Why

Terraform is the cleanest language addition available to this configuration: every surface has an official answer rather than a choice between community options, and one of them is already shipped. `conform` bundles a `terraform_fmt` formatter definition, and `nvim-treesitter` has both `terraform` and `hcl` parsers available — verified 2026-09-11.

It is queued second in `recommendations/ideas.md`, behind the Lua cheatsheet and ahead of JavaScript/TypeScript, because it introduces no unsettled tooling decisions of the kind that make JS/TS an explore-first problem.

## What Changes

- **Register `terraformls`** in `lua/config/lsp.lua` through `vim.lsp.config`/`vim.lsp.enable` with the shared `on_attach` and `capabilities`, exactly as `fsautocomplete`, `marksman` and `lua_ls` are registered.
- **Add formatting** to `lua/plugins/conform.lua`: `terraform_fmt` for the `terraform` and `terraform-vars` filetypes, `hcl` for `hcl`.
- **Add `terraform` and `hcl` parsers** to the `ts.install{...}` list in `lua/plugins/treesitter.lua`.
- **Add `after/ftplugin/terraform.lua`** with indent settings and a `<localleader>` REPL map onto `terraform console`.
- **Document it** — `docs/modules/ROOT/pages/languages/terraform.adoc` and `terraform-cheatsheet.adoc`, two `nav.adoc` entries, and a row in the `languages/setup.adoc` matrix.

Not breaking. No existing filetype, keymap or server is touched.

**`terraform console` is a genuine REPL**, which makes this a better fit for the existing structure than it first appears. It evaluates HCL expressions against the current state and would sit under the same iron.nvim `<localleader>s*` convention that `dotnet fsi` uses for F#, rather than needing a new pattern. Terraform is not usually thought of as having a REPL, so this is worth stating explicitly or the ftplugin will look arbitrary.

## Capabilities

### New Capabilities

- `terraform-lsp`: `terraformls` registration, what it supplies, and what it does not — modelled on the existing `fsharp-lsp` and `markdown-lsp` specs, which both record the gaps as deliberately as the features.
- `terraform-formatting`: `terraform fmt` as the format-on-save path for HCL, and its dependence on the `terraform` binary rather than on a bundled formatter.
- `terraform-ftplugin`: filetype-local settings and the `terraform console` REPL maps.

### Modified Capabilities

- `docs-language-setup`: the Language Setup matrix gains a Terraform row. The requirement that the matrix exists and lists every supported language is unchanged; this adds an entry to it.

## Impact

| Area | Change |
|---|---|
| `lua/config/lsp.lua` | `terraformls` registered |
| `lua/plugins/conform.lua` | `terraform`, `terraform-vars`, `hcl` entries |
| `lua/plugins/treesitter.lua` | `terraform` and `hcl` added to `ts.install` |
| `after/ftplugin/terraform.lua` | new |
| `docs/.../languages/terraform.adoc` + cheatsheet | new |
| `docs/.../nav.adoc`, `languages/setup.adoc` | two xrefs, one matrix row |
| `openspec/TEST_PLAN.md` | new `## Change · add-terraform-support` section |

**Two new prerequisites, neither currently installed.** `terraform-ls` is the language server. The `terraform` binary itself is needed twice over: `conform`'s formatter shells out to `terraform fmt -no-color -`, and `terraformls` leans on the CLI for much of what it answers.

**How the `terraform` binary is provided is an open decision, deliberately not settled here** — see `design.md`. It is the one question in this change that touches a standing principle rather than a technical detail, and it changes what the prerequisites section of the docs has to say.

**Runtime behaviour changes, so manual validation in a live session is required** before push. Validation is additionally blocked until the binary decision is made and acted on: formatting cannot be exercised at all without `terraform` on `$PATH`, and the language server cannot start without `terraform-ls`.

**Deliberately out of scope.** No DAP integration — Terraform has no debugger in the sense `nvim-dap` means. No `tflint` or other linter as a second diagnostic source; that would be the first two-server buffer in this configuration, which is a question JS/TS raises and should be answered there rather than incidentally here. No Terragrunt support, though `conform` ships `terragrunt_hclfmt` if it is ever wanted. No OpenTofu, though `tofu_fmt` exists and the decision below applies identically to it.
