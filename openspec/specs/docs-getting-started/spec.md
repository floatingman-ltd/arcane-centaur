## Purpose

Defines the canonical getting-started guide and its relationship to language-specific guides.

## Requirements

### Requirement: Canonical getting-started guide exists
A `documentation/guides/getting-started.md` file SHALL exist as the single canonical
reference for system-level prerequisites and Neovim installation. It SHALL cover:
- Neovim version requirement (≥ 0.12) with install instructions (AppImage and tarball)
- Docker Engine / Docker Compose install and verification (`docker compose version`)
- General system dependencies shared across language plugins (git, curl, etc.)
- First-run steps after cloning the config

> **Note — Docker coverage gap:** Docker is currently assumed to be present throughout
> the guides (markserv, plantuml-server, pandoc/extra, marp-cli, ollama, SBCL/Swank all
> use `docker compose`) but no guide explains how to install it. The only prior mention
> was in `validation.md` which is being removed from the site. `getting-started.md` is
> the correct home for Docker Engine / Docker Desktop install instructions and a
> `docker compose version` verification step.

#### Scenario: Getting started guide is the install authority
- **WHEN** a reader needs to install or upgrade Neovim
- **THEN** `getting-started.md` SHALL contain the complete AppImage and tarball install instructions
- **THEN** no other guide SHALL duplicate these instructions

### Requirement: Language guides cross-reference getting-started for shared prereqs
Language guides SHALL cross-reference `getting-started.md` for shared system
prerequisites rather than duplicating Neovim version requirements or install
instructions. Each guide SHALL retain only its own language-specific prerequisites.

#### Scenario: dotnet guide no longer contains Neovim upgrade instructions
- **WHEN** a reader opens the .NET guide
- **THEN** it SHALL NOT contain AppImage or tarball install instructions
- **THEN** it SHALL contain a link to getting-started.md for Neovim version requirements

#### Scenario: Language-specific prereqs remain in the language guide
- **WHEN** a guide has prerequisites specific to that language (e.g. Roslyn LSP server)
- **THEN** those prerequisites SHALL remain in the language guide's Prerequisites section
- **THEN** only cross-cutting system prereqs SHALL be moved to getting-started.md
