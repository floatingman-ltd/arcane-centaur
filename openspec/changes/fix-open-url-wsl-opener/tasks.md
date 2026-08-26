## 1. Implementation

- [x] 1.1 In `lua/config/util.lua`, write the URL to the `+` register at the top of `M.open_url`, before any branching.
- [x] 1.2 Echo the URL to the command line via `vim.api.nvim_echo(..., true, {})` on the non-console path, noting that it was copied to the clipboard. Leave the console path echo-free — its INFO notification already carries the URL.
- [x] 1.3 Make the opener list platform-dependent: `{ "wslview", "explorer.exe", "xdg-open", "open" }` when `term.is_wsl`, the existing order otherwise.
- [x] 1.4 Update the function's doc comment to describe the WSL-first order and the clipboard/echo behaviour, and record *why* the order matters (`xdg-open` exits 0 after failing) so it is not "simplified" back later.
- [x] 1.5 Syntax-check: `find . -name '*.lua' -print0 | xargs -0 luac -p`.

## 2. Documentation

- [x] 2.1 `docs/modules/ROOT/pages/other/architecture.adoc:686-687` — replace the flat opener order with the platform-dependent one and describe the clipboard/echo surface.
- [x] 2.2 `docs/modules/ROOT/pages/getting-started.adoc:460-463` — `wslview` is genuinely optional now; correct the claim that its absence leaves only a notification, since `explorer.exe` covers WSL.
- [x] 2.3 `docs/modules/ROOT/pages/content/diagrams.adoc:268-269` and `:391-392` — correct the stated opener order for WSL.
- [x] 2.4 `docs/modules/ROOT/pages/content/presentations.adoc:153` and `:228` — `:MarpPreview` does not use `xdg-open` under WSL; correct it and soften the prerequisite.
- [x] 2.5 (no change needed — the one-line description still reads true) `_readme.adoc:683` — check the one-line description still reads true.
- [x] 2.6 Build the docs site: `./docker/antora/run.sh antora-playbook.yml`.

## 3. Test plan

- [x] 3.1 Add a `## Change · fix-open-url-wsl-opener` section to `openspec/TEST_PLAN.md` with `Prepare` / `Validate` / `Raise PR & merge` / `Post-merge` subsections, following the structure of the existing sections.
- [ ] 3.2 Walk every validation step live in a real Neovim session and tick each box only once genuinely confirmed.

## 4. Close out

- [ ] 4.1 Remove the `open_url` entry from the priority queue and the *Things that seem broken* section of `recommendations/ideas.md`, correcting the recorded diagnosis so the wrong cause is not carried forward.
- [ ] 4.2 After archiving, update the Purpose paragraph of `openspec/specs/open-url/spec.md` by hand — it names the old fixed opener order, and `openspec archive` does not touch Purpose prose.
