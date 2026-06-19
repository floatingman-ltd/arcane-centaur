# Tasks: Add Lisp REPL Containers

## 1. Restructure into docker/lisp-swank/

- [ ] 1.1 Create `docker/lisp-swank/` with the shared `swank-start.lisp` (moved verbatim from `docker/sbcl-swank/swank-start.lisp`)
- [ ] 1.2 Create `docker/lisp-swank/docker-compose.yml`: four services under profiles `sbcl`/`ccl`/`ecl`/`abcl`, each publishing `127.0.0.1:4005:4005` and `127.0.0.1:8080:8080`, mounting `${LISP_DIR:-$PWD}:/lisp`, with the `/proc/net/tcp` healthcheck; build `context: .` + per-impl `dockerfile:`; a bare `up` (no profile) starts SBCL
- [ ] 1.3 Move the existing SBCL Dockerfile to `docker/lisp-swank/sbcl/Dockerfile` (content unchanged; adjust the `COPY` path to the shared `swank-start.lisp`)
- [ ] 1.4 Remove the old `docker/sbcl-swank/` directory
- [ ] 1.5 Verify the SBCL default still builds, reaches `healthy`, and Conjure connects on 4005 (no behavior change)

## 2. CCL container

- [ ] 2.1 Author `docker/lisp-swank/ccl/Dockerfile`: install Clozure CL from the official `clozure/ccl` release tarball; install Quicklisp + Swank
- [ ] 2.2 Verify `docker compose --profile ccl up -d --wait` → healthy → Conjure connects on 4005

## 3. ECL container

- [ ] 3.1 Author `docker/lisp-swank/ecl/Dockerfile`: Debian `ecl` + `gcc` (C toolchain); Quicklisp + Swank
- [ ] 3.2 Verify `docker compose --profile ecl up -d --wait` → healthy → Conjure connects on 4005

## 4. ABCL container

- [ ] 4.1 Author `docker/lisp-swank/abcl/Dockerfile`: JRE/JDK + ABCL; Quicklisp + Swank
- [ ] 4.2 Verify `docker compose --profile abcl up -d --wait` → healthy → Conjure connects on 4005

## 5. Documentation

- [ ] 5.1 Update `docs/modules/ROOT/pages/languages/lisp.adoc`: new `docker/lisp-swank/` paths, per-profile start commands, the ":4005 = active Lisp" contract, the switching one-liner
- [ ] 5.2 Update `docs/modules/ROOT/pages/languages/lisp-cheatsheet.adoc`: per-implementation start commands + `,cc` reconnect
- [ ] 5.3 Update `docs/modules/ROOT/pages/getting-started.adoc`: SBCL + Swank section to the new compose paths
- [ ] 5.4 Fix `CLAUDE.md`: line 30 `cl_lsp` → `—`; line 22 remove/qualify the Lisp `lsp_format = "prefer"` note (no CL LSP attaches)
- [ ] 5.5 Document CLISP + commercial (Allegro, LispWorks) as non-containerized (concise note in `lisp.adoc`, cross-referenced to the arc appendices E/F)

## 6. Validation

- [ ] 6.1 `find . -name '*.lua' -print0 | xargs -0 luac -p` (no Lua changed; keep the repo invariant green)
- [ ] 6.2 Manual: each profile in turn reaches `healthy` and Conjure connects on 4005; down/up swaps the active implementation; `:8080` reachable from the host with a trivial in-container listener
- [ ] 6.3 `openspec validate add-lisp-repl-containers` passes
