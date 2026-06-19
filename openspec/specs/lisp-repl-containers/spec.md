# Spec: lisp-repl-containers

## Purpose

Dockerized Common Lisp REPL servers for SBCL, CCL, ECL, and ABCL — each
connectable from Conjure via Swank on `127.0.0.1:4005`, one active at a time,
with a shared Swank startup configuration and an exposed application port.
CLISP and commercial implementations are documented as non-containerized.

Container layout: `docker/lisp-swank/` with one `docker-compose.yml` (Compose
profiles), one shared `swank-start.lisp`, and per-implementation Dockerfiles
under `sbcl/`, `ccl/`, `ecl/`, and `abcl/`.

## Requirements

### Requirement: SBCL Swank container is the default
The repository SHALL provide an SBCL-based Swank container that starts with a
single `docker compose up -d --wait` (no profile selection) and serves Swank
on `127.0.0.1:4005`. Its build and runtime behavior SHALL match the
pre-existing `docker/sbcl-swank/` setup.

#### Scenario: Default start
- **WHEN** a user runs the documented default `docker compose ... up -d --wait` for the lisp-swank setup with no profile specified
- **THEN** an SBCL Swank server becomes reachable on `127.0.0.1:4005` and Conjure connects with `,cc`

### Requirement: Additional implementation containers
The setup SHALL provide Swank containers for CCL, ECL, and ABCL, each
selectable by a Compose profile (`ccl`, `ecl`, `abcl`) and each serving Swank
on `127.0.0.1:4005`.

#### Scenario: Start an alternate implementation
- **WHEN** a user runs `docker compose --profile ecl up -d --wait`
- **THEN** an ECL Swank server becomes reachable on `127.0.0.1:4005` and Conjure connects to it unchanged

### Requirement: Single active implementation on port 4005
At most one implementation SHALL bind `127.0.0.1:4005` at a time. The active
Common Lisp implementation is defined solely by which container currently owns
that port; Conjure SHALL require no configuration change to switch.

#### Scenario: Switching implementations
- **WHEN** the SBCL container is running and the user brings down its profile and brings up the `ccl` profile
- **THEN** CCL answers on `127.0.0.1:4005` and reconnecting Conjure with `,cc` uses CCL with no other configuration change

### Requirement: Shared Swank startup configuration
All implementation containers SHALL use one shared `swank-start.lisp` that
binds `:interface "0.0.0.0"`, sets `*use-dedicated-output-stream*` to nil, and
starts the server with `:style :spawn` on port 4005.

#### Scenario: Swank startup is single-sourced
- **WHEN** the shared `swank-start.lisp` is edited
- **THEN** the change applies to every implementation container without per-implementation duplication

### Requirement: Application port exposed
The setup SHALL publish an application port (`127.0.0.1:8080:8080`) so a
service running inside the active container is reachable from the host.

#### Scenario: Reach an in-container web service
- **WHEN** a web service listens on port 8080 inside the active container
- **THEN** the host can reach it at `http://127.0.0.1:8080`

### Requirement: Documented implementation switching
Switching implementations SHALL be documented as a Compose one-liner per
implementation; no Neovim/Lua command is required.

#### Scenario: Documentation provides the switch command
- **WHEN** a reader consults the Lisp guide or an implementation appendix
- **THEN** it states the `docker compose --profile <impl> up -d --wait` command and the `,cc` reconnect step

### Requirement: Non-containerized implementations are documented
CLISP and the commercial implementations (Allegro, LispWorks) SHALL be
documented as non-containerized, including the reason (CLISP lacks native
threads for `:style :spawn`; commercial licensing precludes shipping a
container).

#### Scenario: Reader looks up CLISP
- **WHEN** a reader consults the implementations documentation
- **THEN** CLISP is described as non-containerized with its `:style :spawn` limitation noted

### Requirement: Documentation reflects no Common Lisp LSP
Project documentation SHALL state that no Common Lisp LSP is configured. The
`CLAUDE.md` language table SHALL NOT claim a `cl_lsp` server.

#### Scenario: CLAUDE.md language table
- **WHEN** a reader consults the language-support table in `CLAUDE.md`
- **THEN** the Common Lisp row shows no LSP (—), consistent with `lisp.adoc`
