## Context

Adding a language to this configuration means occupying a known set of surfaces, derived from the languages already present rather than invented for this change: an LSP registration in `lua/config/lsp.lua`, an entry in `conform`'s `formatters_by_ft`, parsers in the `ts.install{...}` list, an `after/ftplugin/<ft>.lua`, a guide and a cheatsheet under `docs/modules/ROOT/pages/languages/`, `nav.adoc` entries, and a row in the `languages/setup.adoc` matrix.

Terraform is unusual in how little of that is a judgement call. Verified 2026-09-11:

- `conform` bundles `terraform_fmt`, `tofu_fmt`, `hcl` and `terragrunt_hclfmt` formatter definitions. `terraform_fmt` runs `terraform fmt -no-color -` over stdin.
- `nvim-treesitter` has `terraform` and `hcl` parsers available.
- `terraformls` is HashiCorp's own server, not a community alternative competing with two others.

Against that, one genuine problem: **neither `terraform` nor `tofu` is on `$PATH` on this machine**, and `terraform-ls` is not installed either.

## Goals / Non-Goals

**Goals:**

- Terraform and HCL files highlighted, folded, completed, diagnosed and formatted on save, through the same mechanisms every other language here uses.
- A REPL binding onto `terraform console`, consistent with the existing `<localleader>` convention rather than a new one.
- Documentation that states the binary prerequisites accurately, including which features degrade and how when they are missing.

**Non-Goals:**

- Linting as a second diagnostic source (`tflint`). It would be this configuration's first two-server buffer, and that question belongs to the JavaScript/TypeScript work where it is unavoidable, not here where it is optional.
- DAP. Terraform has no debugger in the sense `nvim-dap` means.
- Terragrunt and OpenTofu. `conform` ships formatters for both; neither is in use here, and adding them speculatively would mean specifying behaviour nobody can validate.
- Any change to an existing filetype, keymap, or server registration.

## Decisions

### D1 — `terraformls` registered exactly like the existing servers

`vim.lsp.config("terraformls", { on_attach = on_attach, capabilities = capabilities })` followed by `vim.lsp.enable`, matching `fsautocomplete`, `marksman` and `janet_lsp` line for line.

No deviation is warranted. The one server in this file that *does* deviate, `lua_ls`, does so because a Neovim configuration is not an ordinary Lua project — a reason with no analogue here.

### D2 — Formatting via `conform`'s bundled `terraform_fmt`, not a custom definition

`formatters_by_ft` gains `terraform` and `terraform-vars` mapped to `terraform_fmt`, and `hcl` mapped to `hcl`.

This differs from how the Lisp family and F# are handled, which use `lsp_format = "prefer"`. That difference is deliberate and worth recording: `terraform fmt` is the canonical formatter for the language, defined by the same project that defines the language, so deferring to the LSP would be choosing the less authoritative of two answers. F# defers to the LSP because Fantomas is reached *through* `fsautocomplete`.

### D3 — The REPL is `terraform console`, under the existing convention

`after/ftplugin/terraform.lua` binds `<localleader>s*` maps onto `terraform console` through iron.nvim, the same shape as F#'s `dotnet fsi`.

Worth stating in the guide rather than leaving to discovery: `terraform console` evaluates expressions against real state, so it is closer to a query tool than to a scratch buffer. That is a meaningful difference from `dotnet fsi` and the Lisp REPLs, where evaluation is side-effect-free by default.

### D4 — **OPEN: how the `terraform` binary is provided**

This is the one decision in this change that is not mine to make, because it sits against a standing principle rather than a technical trade-off.

The repository's stated position is to keep dependencies in containers and not to fall back on native installs. `terraform` is not a service, though — it is a CLI in the same category as `tmux`, `ripgrep` and `fzf`, all of which are documented as host prerequisites in `getting-started.adoc`.

**Option A — native install, documented as a prerequisite.** Consistent with how every other language toolchain here is handled: `dotnet`, `ghc`, `lua-language-server` and `marksman` all run on the host. Format-on-save is a synchronous call on every write, so latency matters, and a local binary is the only option that keeps it imperceptible.

**Option B — a Docker wrapper script on `$PATH`.** Consistent with the containers principle read strictly. `docker run --rm -i hashicorp/terraform fmt -` works for the formatter, since it is a stdin/stdout filter. It is materially worse for `terraformls`, which invokes the CLI itself and would need the wrapper to be visible inside the server's own environment, and it adds container start-up latency to every buffer write.

**Recommendation: Option A**, on the grounds that language toolchains are editor tooling rather than services — the same reasoning that already puts `lua-language-server`, `fsautocomplete` and `marksman` on the host without anyone considering it a violation. But it is recorded as open rather than decided, because the principle was stated deliberately and a proposal is the right place to surface the tension rather than resolve it quietly.

Whichever is chosen changes what the docs must say, which is why implementation should not start until it is settled.

## Risks / Trade-offs

**Validation is blocked until D4 is settled and acted on.** → Nothing about formatting can be exercised without `terraform` on `$PATH`, and the server cannot start without `terraform-ls`. Unlike most changes here, this one cannot be partly validated headlessly first — the headless checks would all fail for want of binaries rather than for want of correctness.

**`terraform console` needs initialised state to be useful.** → It will start in an uninitialised directory but answers little. The test plan needs a fixture that has been through `terraform init`, which means a `testdocs/` fixture with a provider, or accepting that the REPL case is validated against expressions that need no state.

**Format-on-save latency.** → `terraform fmt` is fast natively and slow through a container start. Measured during validation rather than assumed, as was done for the tmux query in `add-remote-session-profile`.

**The `hcl` filetype overlaps with `terraform`.** → Neovim maps `.tf` to `terraform` and `.hcl` to `hcl`; they are different filetypes with different formatters, and conflating them would apply `terraform fmt` to files it does not understand. Specified separately for that reason.

## Open Questions

- **D4, above** — the binary decision. Everything else in this change is settled.
- **Should `terraform-ls` be added to the language-server install documentation** in `languages/setup.adoc` as a required or an optional prerequisite? Every other server there is required for its language; this would follow, but it is worth confirming the matrix means "required for full support" rather than "installed here".
