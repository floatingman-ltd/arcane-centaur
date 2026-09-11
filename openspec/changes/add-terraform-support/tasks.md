## 0. Blocked until the binary decision is made

- [ ] 0.1 Settle **D4** in `design.md` — whether the `terraform` binary is a documented host prerequisite or is provided through a Docker wrapper. Do not start section 1 before this: it changes what the docs must say, and it is the difference between a prerequisites paragraph and a wrapper script that has to be maintained
- [ ] 0.2 Install `terraform-ls`, and `terraform` per the D4 decision. Record the versions — every other language guide states the versions it was validated against
- [ ] 0.3 Confirm both resolve: `terraform version` and `terraform-ls --version`

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
