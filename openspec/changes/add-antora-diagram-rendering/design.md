## Context

Adding diagrams to an Antora site normally means one line in the playbook. It is more than that here for three reasons, each measured on 2026-09-21 rather than assumed.

**The obvious component is the wrong one.** `asciidoctor-diagram` is a Ruby gem. Antora runs Asciidoctor.js under Node, and cannot load Ruby extensions. The Asciidoctor project's own answer for JavaScript toolchains is `asciidoctor-kroki`, which delegates rendering to a Kroki server over HTTP.

**The version that installs by default will not work.** `asciidoctor-kroki` 1.0.0 and later require Asciidoctor.js 4, which Antora 3 does not ship. Measured in the image this repository actually runs:

```
$ docker run --rm antora/antora --version
@antora/cli: 3.1.14
@antora/site-generator: 3.1.14
$ docker run --rm --entrypoint node antora/antora --version
v16.20.2
```

So the pin is `asciidoctor-kroki@latest-0`, currently 0.18.1.

**Installing it globally in the container is not enough.** Measured — a `Dockerfile` doing `npm i -g asciidoctor-kroki@latest-0` builds fine and then fails at require time:

```
code: 'MODULE_NOT_FOUND',
requireStack: [ '/antora/[eval]' ]
```

`npm root -g` is `/usr/local/lib/node_modules`, which is not on Node's resolution path. With `NODE_PATH` set to it, the module loads:

```
$ NODE_PATH=$(npm root -g) node -e 'console.log(typeof require("asciidoctor-kroki").register)'
function
```

The current state otherwise: `antora-playbook.yml` has no `asciidoc` key at all, no page in `docs/` contains an `image::` or a diagram block, and `docker/antora/run.sh` runs the stock `antora/antora` image with the working tree mounted at `/antora`.

## Goals / Non-Goals

**Goals:**

- Diagram blocks in `.adoc` pages render to images in the published site.
- The renderer is self-hosted, consistent with the containers-first rule.
- A missing renderer produces a legible failure rather than a silently diagram-free page.
- The six ASCII diagrams in the terminals primer become rendered diagrams, proving the path end to end.

**Non-Goals:**

- Changing any in-editor preview. `:PumlPreview`, `:PumlPreviewAscii`, markdown-preview.nvim and the Confluence publisher keep the PlantUML server on 8080.
- Removing ASCII diagrams elsewhere. They are fine where they are, and a rendered image is worse than ASCII in a terminal.
- Diagram types beyond what the base Kroki image provides. Mermaid, BPMN and Excalidraw need companion containers and nothing here needs them yet.
- Publishing pipeline changes. How the built site reaches GitHub Pages is untouched.

## Decisions

### D1 — `asciidoctor-kroki`, pinned to `latest-0`

`asciidoc.extensions: [asciidoctor-kroki]` in the playbook, with the package pinned to the `0.x` line.

*Alternative rejected — `asciidoctor-diagram`.* The component this change was originally scoped around. It cannot work: wrong language runtime. Recording it here so the question is not reopened.

*Alternative rejected — `asciidoctor-plantuml.js`.* A JavaScript PlantUML extension does exist, but upstream describes it as no longer maintained and points at Kroki instead.

*Alternative considered — leave it as ASCII.* Genuinely defensible, and the reason this is a proposal rather than a patch. ASCII costs nothing, has no runtime, and renders in a terminal as well as a browser. The case against is that it does not scale past what the terminals page already does, and that the repository renders PlantUML in three other places already.

### D2 — Self-hosted Kroki, not kroki.io

`docker/kroki/docker-compose.yml`, base `yuzutech/kroki` image, gateway on port 8000.

The public `kroki.io` instance would need no infrastructure. It is rejected on two grounds: it sends documentation content to a third party at build time, and the containers-first rule already governs every other service here. The base image covers PlantUML, GraphViz, D2, Ditaa and around two dozen others without companions.

Port 8000 rather than the default-adjacent 8080, which `plantuml-server` already holds.

### D3 — A thin image over `antora/antora`, with `NODE_PATH` set

`docker/antora/Dockerfile`:

```dockerfile
FROM antora/antora:latest
USER root
RUN npm i -g asciidoctor-kroki@latest-0
USER node
ENV NODE_PATH=/usr/local/lib/node_modules
```

`run.sh` builds or pulls this image instead of running `antora/antora` directly, and must give the container a route to Kroki. The two are on different Docker networks by default, so the wrapper either joins the Kroki compose network or passes a reachable host address.

*Alternative rejected — install into the mounted working tree.* Antora resolves extensions relative to the playbook, so a `node_modules/` beside the playbook works without a custom image. It would put a Node dependency tree in the repository root of a Neovim configuration, and `package.json` at top level would be misleading about what this project is.

### D4 — Kroki does not replace `plantuml-server`

Two services, each with one consumer: Kroki for the site build, `plantuml-server` for in-editor preview and Confluence publishing.

Consolidating is tempting — Kroki bundles PlantUML and accepts the same deflate+base64 encoded payloads, so one service could serve both. It is rejected for this change because `http://localhost:8080` is hardcoded at four call sites (`lua/plugins/plantuml.lua` twice, `lua/plugins/markdown.lua`, and `lua/config/confluence.lua` behind a `PLANTUML_SERVER` env default), and changing them means re-validating three working preview paths for no gain to the goal here. Worth revisiting as its own change if running two renderers becomes annoying.

### D5 — A missing Kroki service fails the build loudly

If the extension cannot reach Kroki, the build must fail with a message naming the service, not emit a page with a broken image.

This is the opposite of how the rest of this repository degrades — a missing `terraform` or `stylua` leaves the editor working. The difference is who is affected and when. A degraded editor inconveniences one person immediately and visibly; a silently diagram-free page is published and read by people who have no idea a diagram was meant to be there. `asciidoctor-kroki`'s actual behaviour on an unreachable server is **not yet measured** and is the first thing to establish during implementation — see Open Questions.

## Risks / Trade-offs

**Building the docs gains a prerequisite.** → Today `./docker/antora/run.sh` needs only Docker. After this it needs a Kroki container running too. Mitigated by the wrapper starting Kroki itself, or failing with an instruction rather than a stack trace. This must be in `getting-started.adoc` either way.

**Antora 3 pins the extension to an old line.** → `latest-0` is 0.18.1 and the project's attention is on 1.x. If Antora 4 lands, the pin should be revisited; if a 0.x bug bites before then, the fix may only exist in 1.x. Recorded so the pin is understood as a constraint rather than a preference.

**Node 16 in the Antora image is end-of-life.** → It works, and this change does not make it worse, but it narrows what can be installed alongside. Not this change's problem to fix; worth stating so the next person does not discover it while debugging.

**Rendered diagrams are worse in a terminal.** → The ASCII versions in the terminals primer are readable in Neovim; SVG is not. Anyone reading the `.adoc` source rather than the site loses something. Accepted, and the reason the change converts one page rather than all of them.

**Two diagram services running.** → ~200 MB of container for Kroki on top of the PlantUML server, for a docs build that runs occasionally. D4 accepts this deliberately; the alternative was re-validating working preview paths.

## Migration Plan

Additive throughout. Register the extension, add the service, convert one page, document the prerequisite.

Rollback is removing the `asciidoc` key from the playbook and reverting the one converted page. The Kroki container can be left in place or stopped; nothing else references it.

## Open Questions

- **What does `asciidoctor-kroki` do when the Kroki server is unreachable?** D5 states the wanted behaviour without knowing the actual one. Establish this first: if the extension warns and continues, meeting D5 needs the wrapper to health-check Kroki before invoking Antora.
- **How should the Antora container reach Kroki?** Joining the compose network is cleanest; `--add-host` or a published port are simpler. Depends on whether `run.sh` starts Kroki itself.
- **Does `kroki-fetch-diagram` matter here?** It makes Antora download images at build time instead of emitting Kroki URLs into the HTML. For a site published to GitHub Pages it is effectively required, since a reader's browser cannot reach a Kroki container on this machine. Confirm during implementation, and treat a published page whose images point at `localhost:8000` as a failed validation.
- **Is the Kroki server probe still outstanding?** Rendering PlantUML through a self-hosted Kroki container was not verified — the image pull failed with a Docker credential-helper error unrelated to Kroki. The extension-loads probe and the version constraints above were measured; the render path was not.
