## 1. Install

- [x] 1.1 Install `marksman` from the `2026-02-08` GitHub release asset `marksman-linux-x64` into `~/.local/bin/marksman`, mode 755. Observed digest `be5098e8213219269c47fc0d916a66fa31ce0602ec967475c722260aabf26087` — the release publishes no checksum file to verify against.
- [x] 1.2 Install `fsautocomplete` via `dotnet tool install -g fsautocomplete` (0.83.0 → `~/.dotnet/tools`).
- [x] 1.4 Install `fantomas` via `dotnet tool install -g fantomas` (7.0.6 → `~/.dotnet/tools`). Found during the LS.4/LS.5 pre-check: fsautocomplete delegates F# formatting to Fantomas and does not ship it, and its absence raises a blocking interactive install prompt on every write rather than skipping formatting. This makes the F# side of the change a two-binary install.
- [x] 1.5 Repoint the LSP cases at `testdocs/hello.fsx` and give it real content. A bare `.fs` outside any project is never added to fsautocomplete's loaded projects: every request fails with `Couldn't find <path> in LoadedProjects`, and opening the file alone logs an `UnhandledPromiseRejection`. `testdocs/hello.fs` stays as the loose-file indent/fold fixture, with its stale "fsautocomplete is not installed" comment corrected.
- [x] 1.3 Confirm both attach and record their advertised capabilities, rather than trusting either README.

## 2. Configuration

- [x] 2.1 Update the stale comment in `lua/plugins/ufo.lua` — it says marksman is "configured but absent" and that the lsp slot "would be dead weight" for want of a server. The conclusion still holds but the reason is now that marksman advertises no `foldingRangeProvider`.
- [x] 2.2 Confirm no other code change is needed: F# folding and formatting activate through paths that already exist.
- [x] 2.3 Syntax-check: `find . -name '*.lua' -print0 | xargs -0 luac -p`.

## 3. Documentation

- [x] 3.1 `docs/modules/ROOT/pages/editor/code-intelligence.adoc:32` — replace `sudo apt install marksman` with the GitHub release install. The package does not exist.
- [x] 3.2 `docs/modules/ROOT/pages/content/diagrams.adoc:390` — same correction.
- [x] 3.3 `docs/modules/ROOT/pages/other/architecture.adoc:100` — the bare ✅ against marksman implied it was active while it was absent. Keep the mark now it is true, but make the list say what it is asserting.
- [x] 3.4 Add a Markdown row and section to `docs/modules/ROOT/pages/languages/setup.adoc`. **Not** the getting-started prerequisite table as `ideas.md` proposed — the `docs-getting-started` spec keeps language-specific prereqs off that page, and `fsautocomplete` is already in the setup matrix correctly.
- [x] 3.5 Record what each server does *not* provide where a reader would look for it — marksman has no folding or formatting, and F# still has no indent support despite now having an LSP.
- [x] 3.7 Document Fantomas as a required F# binary and the bare-`.fs` limitation: `languages/setup.adoc` (new dependency row), `editor/code-intelligence.adoc` (install column plus two notes), `languages/dotnet.adoc` (F# formatting section, global-tools install block, dependency table). Also record that Fantomas restructures code rather than only re-indenting it.
- [x] 3.6 Build the docs site: `./docker/antora/run.sh antora-playbook.yml`.

## 4. Test plan

- [x] 4.1 Add a `## Change · install-language-servers` section to `openspec/TEST_PLAN.md` with `Prepare` / `Validate` / `Raise PR & merge` / `Post-merge` subsections, following the structure of the existing sections. Cover the two silent activations especially — F# format-on-save and F# LSP folds arrive with no edit, so nothing in the diff points at them.
- [ ] 4.2 Walk every validation step live in a real Neovim session and tick each box only once genuinely confirmed.

## 5. Close out

- [ ] 5.1 Remove the entry from the priority queue in `recommendations/ideas.md`, keeping the F# indent gap — which this change explicitly does not fix — as its own item.
- [ ] 5.2 Delete the stale `indentexpr` entry still sitting under *Things that seem broken*; it was fixed by `align-treesitter-providers` and is already listed as shipped further up the same file.
- [ ] 5.3 After archiving, correct the Purpose of `openspec/specs/code-folding/spec.md` by hand. It still says "treesitter folding is deliberately disabled; markdown uses indent only", which `align-treesitter-providers` overturned and which its own line 48 contradicts. `openspec archive` does not touch Purpose prose.
