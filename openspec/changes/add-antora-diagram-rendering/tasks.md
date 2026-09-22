## 0. Settle the two unknowns before building anything

Both are open questions in `design.md`, and both change what the rest of this list looks like.

- [ ] 0.1 Pull `yuzutech/kroki` and confirm it renders. The probe on 2026-09-21 failed on a Docker credential-helper error unrelated to Kroki, so this is unverified: `docker run -d -p 8000:8000 yuzutech/kroki`, then POST a PlantUML payload to `/plantuml/svg` and check an SVG comes back
- [ ] 0.2 Establish what `asciidoctor-kroki` does when the Kroki server is unreachable — warn and continue, or fail. D5 states the wanted behaviour without knowing the actual one
- [ ] 0.3 If it warns and continues, decide where the health check lives so D5 is still met. `docker/antora/run.sh` is the obvious home
- [ ] 0.4 Establish whether `kroki-fetch-diagram: true` is required for the published site. A page whose `<img>` points at `localhost:8000` is a failed build, not a passing one — the reader's browser cannot reach this machine
- [ ] 0.5 Decide how the Antora container reaches Kroki: join the compose network, publish a port and use a host address, or have `run.sh` start both. Record which and why

## 1. The Kroki service

- [ ] 1.1 Create `docker/kroki/docker-compose.yml` using the base `yuzutech/kroki` image, following the shape of `docker/plantuml-server/docker-compose.yml`
- [ ] 1.2 Bind the gateway to a port that does not collide with 8080, which `plantuml-server` holds. Bind to `127.0.0.1` as `plantuml-server` does
- [ ] 1.3 Pin the image tag rather than tracking `latest`, so diagram output cannot change without a commit
- [ ] 1.4 Add no companion containers. Mermaid, BPMN and Excalidraw are out of scope and the base image covers PlantUML, GraphViz, D2 and Ditaa
- [ ] 1.5 Write `docker/kroki/README.md` stating what it serves, why it is separate from `plantuml-server` (D4), and the start command
- [ ] 1.6 Confirm both services run together and both answer

## 2. The Antora image

- [ ] 2.1 Create `docker/antora/Dockerfile` — `FROM antora/antora:latest`, install `asciidoctor-kroki@latest-0` globally
- [ ] 2.2 Set `ENV NODE_PATH=/usr/local/lib/node_modules`. Without it the module is installed but unresolvable — measured 2026-09-21, `MODULE_NOT_FOUND` with `requireStack: ['/antora/[eval]']`
- [ ] 2.3 Confirm the pin resolves to a `0.x` version. 1.x requires Asciidoctor.js 4 and Antora 3.1.14 does not ship it
- [ ] 2.4 Confirm `require("asciidoctor-kroki").register` is a function inside the built image
- [ ] 2.5 Update `docker/antora/run.sh` to build or use this image, keeping the existing `--user` mapping so build output stays owned by the invoking user
- [ ] 2.6 Give the container a route to Kroki, per the decision in 0.5
- [ ] 2.7 Confirm `./docker/antora/run.sh antora-playbook.yml` still builds the site unchanged with no diagram blocks present anywhere

## 3. Playbook wiring

- [ ] 3.1 Add an `asciidoc.extensions` key to `antora-playbook.yml` listing `asciidoctor-kroki`. The file currently has no `asciidoc` key at all
- [ ] 3.2 Add `kroki-server-url` pointing at the local service
- [ ] 3.3 Add `kroki-fetch-diagram` if 0.4 found it necessary
- [ ] 3.4 Build and confirm the extension is loaded rather than silently ignored — a registered extension that fails to load is the failure mode to watch for here

## 4. First diagram

- [ ] 4.1 Convert one of the six ASCII diagrams in `other/terminals-ssh-tmux-mosh.adoc` to a `[plantuml]` block and build. Start with the tmux environment freeze, the most structural of the six
- [ ] 4.2 Confirm the built page contains an image and not a code block
- [ ] 4.3 Confirm the image source is not a `localhost` URL
- [ ] 4.4 Compare the rendered diagram against the ASCII original for meaning, not just for rendering. If the PlantUML version says less, keep the ASCII one and record why
- [ ] 4.5 Convert the remaining five only if 4.4 came out in favour

## 5. Failure behaviour

- [ ] 5.1 Stop Kroki and build. Confirm the outcome matches D5 — a failure naming the service, not a published page with a missing image
- [ ] 5.2 If the raw behaviour is warn-and-continue, implement the check decided in 0.3 and re-test
- [ ] 5.3 Confirm the failure message is intelligible to someone who has not read this change

## 6. Documentation

- [ ] 6.1 Add the Kroki prerequisite to the docs build instructions in `getting-started.adoc`. Building the docs currently needs only Docker; after this it needs a running service
- [ ] 6.2 Add the fourth workflow to `content/diagrams.adoc`, which today documents three and describes PlantUML as browser-preview only
- [ ] 6.3 State the split plainly: Kroki renders the site, `plantuml-server` renders in-editor previews and Confluence, and the two are not interchangeable today (D4)
- [ ] 6.4 Note the Antora 3 version pin where someone upgrading Antora will find it
- [ ] 6.5 Build the docs and check the rendered pages

## 7. Validation

- [ ] 7.1 Add a `## Change · add-antora-diagram-rendering` section to `openspec/TEST_PLAN.md` with branch, prerequisites, and numbered `Prepare` / `Validate` / `Raise PR & merge` / `Post-merge` subsections
- [ ] 7.2 Include a case for the published-site check. Local rendering passing is not evidence the published page works, and group A of `openspec/DEFERRED_VERIFICATION.md` records three changes that already made this mistake
- [ ] 7.3 Walk every step in a live session
- [ ] 7.4 Confirm no in-editor preview regressed — `:PumlPreview`, `:PumlPreviewAscii`, markdown preview, and a Confluence publish if credentials are available
- [ ] 7.5 Confirm the site builds from a clean state with only the documented prerequisites
- [ ] 7.6 Tick each `- [ ]` only once genuinely confirmed, logging any defect and its fix inline as a blockquote note

## 8. Close out

- [ ] 8.1 Raise the PR once every validation step is ticked
- [ ] 8.2 Archive the change, then immediately write the `docs-diagram-rendering` Purpose by hand — `openspec archive` leaves a `TBD` placeholder no delta can fill
- [ ] 8.3 If D4 still rankles after living with two renderers, log consolidating them in `recommendations/ideas.md` as its own change rather than reopening this one
