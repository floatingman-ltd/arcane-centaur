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

### D4 — **DECIDED 2026-09-11: a Docker wrapper script on `$PATH`**

The containers principle applies. `terraform` is provided by a wrapper rather than installed on the host, and the wrapper is not the naive form — that was measured and found broken.

**The wrapper must use an identity mount.** Mounting the working directory under a different path inside the container breaks absolute paths, and `terraform-ls` passes absolute paths. Measured on 2026-09-11:

```sh
# BROKEN — the container cannot see a host absolute path
docker run --rm -i -v "$PWD:/work" -w /work hashicorp/terraform fmt "$PWD/main.tf"
#   Error: No file or directory at ../tmp/.../main.tf

# CORRECT — same path inside and out, so absolute paths resolve
docker run --rm -i -v "$PWD:$PWD" -w "$PWD" --user "$(id -u):$(id -g)" \
  hashicorp/terraform fmt "$PWD/main.tf"
```

`--user` matters independently: without it, anything terraform writes — `.terraform/`, lock files, formatted output — is owned by root on the host. With it, files stay owned by the invoking user, confirmed by `stat` after an in-place format.

**Formatting does not need the mount at all.** `conform` invokes `terraform fmt -no-color -`, a pure stdin/stdout filter, verified producing correctly formatted output with no volume attached. The mount exists for `terraform-ls` and for any command operating on real files.

**Measured cost: ~530-606 ms per invocation** over five warm-image runs, against `conform`'s 2000 ms `timeout_ms`. It fits with roughly 3.3x headroom, but it is a perceptible pause on every write where a native binary would be 10-30 ms. That is the price of the principle, and it is recorded as a number rather than an impression so that a later reader can judge it rather than re-derive it.

**`terraform-ls` itself runs natively, not containerised.** It is a language server — editor tooling in the same category as `lua_ls`, `marksman` and `fsautocomplete`, all of which run on the host without anyone considering it a violation. The principle bites on the tool being *operated*, not on the editor's own machinery. A native server invoking a containerised CLI is exactly why the identity mount is non-negotiable: the two must agree on what a path means.

*Alternative rejected — native `terraform` install.* Recommended in the first draft of this design, on the grounds that language toolchains are editor tooling. Overruled deliberately: `terraform` is the tool being operated on infrastructure, not machinery the editor needs to function, and the containers principle was stated to cover exactly that case. The ~500 ms is the cost of holding the line, and it is affordable here because format-on-save is the only hot path.

## Risks / Trade-offs

**Validation is blocked until the wrapper and `terraform-ls` are installed.** → D4 is now settled, but nothing about formatting can be exercised until the wrapper is on `$PATH`, and the server cannot start without `terraform-ls`. Unlike most changes here, this one cannot be partly validated headlessly first — the checks would fail for want of binaries rather than for want of correctness.

**`terraform console` needs initialised state to be useful.** → It will start in an uninitialised directory but answers little. The test plan needs a fixture that has been through `terraform init`, which means a `testdocs/` fixture with a provider, or accepting that the REPL case is validated against expressions that need no state.

**Format-on-save latency.** → Measured, not assumed: **~530-606 ms** per invocation over five warm-image runs, against `conform`'s 2000 ms timeout. Fits with ~3.3x headroom; a native binary would be 10-30 ms. The pause is perceptible on every write and is the accepted cost of D4. Re-measure on a cold image, where the first format of a session also pays an image pull or load.

**The `hcl` filetype overlaps with `terraform`.** → Neovim maps `.tf` to `terraform` and `.hcl` to `hcl`; they are different filetypes with different formatters, and conflating them would apply `terraform fmt` to files it does not understand. Specified separately for that reason.

## Open Questions

- **Modules outside the working directory are not mounted.** The wrapper mounts `$PWD` only, so a module referenced as `../modules/foo` is invisible inside the container. Whether that matters depends on repository layout, and it is the most likely way this wrapper fails in real use rather than in a fixture. Decide during implementation whether to mount a repository root instead of `$PWD`.
- **`terraform-ls` has not been exercised against the wrapper at all.** It is not installed, so the interaction between a native server and a containerised CLI is reasoned about rather than observed. The identity mount makes it *should-work*; that is not the same as working.
- **Should `terraform-ls` be added to `languages/setup.adoc` as required or optional?** Every other server there is required for its language; this would follow, but it is worth confirming the matrix means "required for full support" rather than "installed here".
