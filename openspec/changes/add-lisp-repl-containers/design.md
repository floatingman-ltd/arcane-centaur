# Design: Add Lisp REPL Containers

## Context

The repository ships one CL REPL container, `docker/sbcl-swank/`:

- `Dockerfile`: `debian:bookworm-slim` + SBCL + Quicklisp; pre-fetches Swank; copies `swank-start.lisp`.
- `docker-compose.yml`: publishes `127.0.0.1:4005:4005`, mounts `${LISP_DIR:-$PWD}:/lisp`, uses a `/proc/net/tcp` healthcheck for port 4005 (hex `0FA5`).
- `swank-start.lisp`: `(swank:create-server :port 4005 :dont-close t :style :spawn :interface "0.0.0.0")` with `swank::*use-dedicated-output-stream*` set to nil.

Conjure connects to `127.0.0.1:4005` (`lua/plugins/lisp.lua`). The key fact: **Swank speaks one wire protocol regardless of the underlying Common Lisp implementation**, and Conjure neither knows nor cares which implementation answers. That single fact is what makes four implementations cost almost nothing in editor complexity — the only things that vary per implementation are the base image, how the implementation + Quicklisp + Swank install, and how an executable is produced.

## Goals / Non-Goals

**Goals:**

- Four implementations — SBCL (default), CCL, ECL, ABCL — each runnable as a Swank container reachable on `127.0.0.1:4005`.
- The identical ~75% (shared `swank-start.lisp`, port map, volume mount, healthcheck) single-sourced; only per-impl Dockerfiles differ.
- SBCL stays exactly as trivial as today.
- An application port exposed for the web-service lesson.
- Each implementation fully readable in its own Dockerfile (for the learning appendices).

**Non-Goals:**

- No `:LispImpl` Lua command in this change (deferred; the down/up one-liner is documented).
- No CLISP or commercial containers (documented as non-containerized).
- No Common Lisp LSP (decided REPL-only; the live image via Swank is the intelligence layer).
- No change to Conjure configuration or the `4005` port.
- No automatic or concurrent multi-implementation running — exactly one profile up at a time.

## Decisions

**1. The ":4005 contract" — whoever owns the port is the active Lisp.**
All four services publish `127.0.0.1:4005:4005`. Because a host port can be bound by only one container, "switching" reduces to: down the running profile, up the chosen one. Conjure reconnects to the same socket with `,cc`; no reconfiguration. The editor side stays stateless.

**2. One profiles-based compose + shared `swank-start.lisp` + per-impl Dockerfiles** (vs. four separate dirs, vs. one parameterized Dockerfile).
~75% of each setup is identical, so copying it four times (four separate dirs) makes a Swank fix a 4× chore. A single parameterized Dockerfile (`ARG IMPL`) is DRYest but buries per-impl differences in conditionals — the opposite of what the learning appendices need to *show*. The middle path — shared `swank-start.lisp`, one compose with `profiles: [sbcl|ccl|ecl|abcl]`, and a readable Dockerfile per impl — single-sources the identical parts while keeping each implementation visible. Set the Compose build `context` to `docker/lisp-swank/` and select per-impl Dockerfiles via `dockerfile:` so each can `COPY` the shared `swank-start.lisp` from the context root.

**3. Per-implementation install methods.**
- **SBCL**: Debian `sbcl` + Quicklisp (existing recipe, carried over verbatim). Executable via `save-lisp-and-die`.
- **CCL** (Clozure): no clean Debian package; install from the official `clozure/ccl` release tarball into the image. Executable via `save-application`.
- **ECL**: Debian `ecl` + a C toolchain (`gcc`) — ECL compiles through C. Executable is a small native binary.
- **ABCL**: needs a JRE/JDK (`default-jre-headless`) — runs on the JVM. Executable distributed as an uberjar.
All four support native threads, so the shared `:style :spawn` startup works unchanged.

**4. Application port 8080 exposed alongside 4005.**
The web-service lesson runs a Hunchentoot/Clack service inside the container; publishing `127.0.0.1:8080:8080` lets the host `curl` it. Exposed on all profiles (harmless when unused).

**5. SBCL default stays untouched-simple.**
The SBCL Dockerfile/run is the existing one moved into `sbcl/`; a bare `docker compose up -d --wait` (no `--profile`) starts SBCL. The migration is a move + extract-shared, not a behavior change.

**6. CLISP and commercial implementations are documented, not shipped.**
CLISP is a bytecode interpreter with no native threads, so the shared `:style :spawn` startup does not apply — it would need a `:style nil`/`:sigio` fallback, and the project is essentially dormant. Allegro (free Express edition is restricted) and LispWorks (GUI-oriented, no free Docker) cannot ship as containers for licensing reasons. All three are written up in the learning arc's appendices instead.

## Risks / Trade-offs

- [Migrating `docker/sbcl-swank/` could destabilize the one path everyone uses] → Preserve the exact SBCL Dockerfile content and compose settings; verify the default `up -d --wait` → healthy → Conjure connects, before and after the move.
- [Per-impl install recipes are unverified] → Treat each non-SBCL container as a spike: confirm the CCL tarball URL/arch, the ECL Quicklisp+gcc build, and the ABCL JDK + Quicklisp path before marking its task done. Record the working recipe in the appendix.
- [ABCL image is heavy (JDK)] → Accepted; it is opt-in and only built when its profile is selected.
- [`COPY` of a shared file across build contexts can be fiddly] → Context root at `docker/lisp-swank/`, per-impl `dockerfile:` paths, `swank-start.lisp` at the context root.
- [Catalog-first switching means remembering a compose line] → Documented prominently in `lisp.adoc` and each appendix; the thin `:LispImpl` helper remains an easy follow-up if the manual step grates.
