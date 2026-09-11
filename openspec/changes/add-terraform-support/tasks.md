## 0. Provide the toolchain

**D4 decided 2026-09-11: Docker wrapper, not a native install.** See `design.md` for the measured evidence behind the wrapper's shape.

- [ ] 0.1 Create `~/.local/bin/terraform` as a wrapper. It **must** use an identity mount and drop privileges — `-v "$PWD:$PWD" -w "$PWD" --user "$(id -u):$(id -g)"`. A renamed mount such as `-w /work` breaks absolute paths, which `terraform-ls` passes; verified failing on 2026-09-11
- [ ] 0.2 Pin the image tag rather than tracking `latest`, so a formatter does not change behaviour underneath the repository without a commit
- [ ] 0.3 Confirm `terraform version` resolves through the wrapper, and that Neovim itself sees it — `:lua print(vim.fn.exepath("terraform"))`
- [ ] 0.4 Confirm `terraform fmt -no-color -` formats over stdin with no volume attached, which is the path `conform` actually uses
- [ ] 0.5 Confirm a file formatted in place stays owned by the invoking user, not root
- [ ] 0.6 Install `terraform-ls` **natively** — it is editor tooling, in the same category as `lua_ls` and `marksman`, and is deliberately not containerised
- [ ] 0.7 Record the image tag and the `terraform-ls` version; every language guide states what it was validated against
- [ ] 0.8 Decide whether the wrapper should mount a repository root rather than `$PWD`, so that `../modules/foo` references resolve. This is the most likely real-world failure and will not show up in a single-directory fixture

## 1. Language server

- [ ] 1.1 Register `terraformls` in `lua/config/lsp.lua` with the shared `on_attach` and `capabilities`, in the same shape as `fsautocomplete` and `marksman`
- [ ] 1.2 Confirm it attaches to a `.tf` buffer and that the shared keymaps are bound
- [ ] 1.3 Confirm Neovim starts cleanly with `terraform-ls` absent from `$PATH` — the missing-binary case every other server spec requires
- [ ] 1.4 Syntax-check: `find . -name '*.lua' -print0 | xargs -0 luac -p`

## 2. Treesitter

- [ ] 2.1 Add `terraform` and `hcl` to the `ts.install{...}` list in `lua/plugins/treesitter.lua`
- [ ] 2.2 Confirm both parsers install and highlighting is active in a `.tf` and a `.hcl` buffer
- [ ] 2.3 Check whether either parser ships an `indents.scm`. The `has_indent_query` helper in that file resolves this at runtime, so no list needs editing — but confirm the outcome, since treesitter indenting without a query is worse than none

## 3. Formatting

- [ ] 3.1 Map `terraform` and `terraform-vars` to `terraform_fmt`, and `hcl` to `hcl`, in `lua/plugins/conform.lua`
- [ ] 3.2 Confirm a badly-formatted `.tf` file is rewritten on save
- [ ] 3.3 Confirm a `.hcl` file uses the `hcl` formatter and not `terraform_fmt`
- [ ] 3.4 Confirm that with `terraform` absent, writing a buffer leaves it unchanged and does not block the write or spam errors
- [ ] 3.5 Measure format-on-save latency and record the number — especially if D4 resolved to the Docker wrapper, where container start-up is paid on every write

## 4. Filetype plugin

- [ ] 4.1 Create `after/ftplugin/terraform.lua` with HCL-conventional indent settings
- [ ] 4.2 Bind `<localleader>s*` maps onto a `terraform console` REPL via iron.nvim, matching the F# shape, each with a `desc`
- [ ] 4.3 Confirm which-key surfaces the maps
- [ ] 4.4 Confirm the REPL starts and evaluates an expression needing no state (e.g. `1 + 1`, `upper("x")`)

## 5. Documentation

- [ ] 5.1 Write `docs/modules/ROOT/pages/languages/terraform.adoc` following `docs-guide-template` — usage-first, dynamic jump menu, Prerequisites distinct from Setup
- [ ] 5.2 Write `docs/modules/ROOT/pages/languages/terraform-cheatsheet.adoc`
- [ ] 5.3 State the `terraform` binary prerequisite, and that it is needed by **both** the formatter and the server — not only the formatter, which is the easier half to guess
- [ ] 5.4 Document that `terraform console` evaluates against real state, unlike the other REPLs here
- [ ] 5.5 Add both pages to `nav.adoc`, as a Guide/Cheatsheet pair
- [ ] 5.6 Add the Terraform row to `languages/setup.adoc`
- [ ] 5.7 Build the docs (`./docker/antora/run.sh antora-playbook.yml`) and check the rendered pages

## 6. Validation

- [ ] 6.1 Add a `## Change · add-terraform-support` section to `openspec/TEST_PLAN.md` with branch, prerequisites, and numbered `Prepare` / `Validate` / `Raise PR & merge` / `Post-merge` subsections
- [ ] 6.2 Decide the REPL fixture: either a `testdocs/` Terraform fixture that has been through `terraform init`, or accept that the REPL case only covers stateless expressions. Record which, and why
- [ ] 6.3 Walk every step in a live session
- [ ] 6.4 Confirm no other language regressed — open an F#, Lua and markdown buffer and check diagnostics, formatting and keymaps behave as before
- [ ] 6.5 Tick each `- [ ]` only once genuinely confirmed, logging any defect and its fix inline as a blockquote note

## 7. Close out

- [ ] 7.1 Raise the PR once every validation step is ticked
- [ ] 7.2 Remove the Terraform entry from the priority queue in `recommendations/ideas.md`, and trim entry 1c to whatever remains unshipped
- [ ] 7.3 Archive the change, then immediately write the Purpose for each of the three new capabilities by hand — `openspec archive` leaves a `TBD` placeholder that no delta can fill, and this change creates three of them
