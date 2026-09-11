## ADDED Requirements

### Requirement: HCL is formatted on save by the canonical formatter
`lua/plugins/conform.lua` SHALL map the `terraform` and `terraform-vars` filetypes to `conform`'s bundled `terraform_fmt`, and the `hcl` filetype to `hcl`. Formatting SHALL NOT defer to the language server. `terraform fmt` is defined by the same project that defines the language, so it is the authoritative formatter rather than one of several options.

#### Scenario: A Terraform file is formatted on write
- **WHEN** the user writes a `.tf` buffer whose contents are not canonically formatted
- **THEN** the buffer SHALL be rewritten by `terraform fmt`

#### Scenario: HCL and Terraform are treated as distinct filetypes
- **WHEN** the user writes a `.hcl` file
- **THEN** the `hcl` formatter SHALL be used rather than `terraform_fmt`
- **AND** `terraform fmt` SHALL NOT be applied to files it does not parse

#### Scenario: Formatter absent
- **WHEN** the `terraform` binary is not on `$PATH`
- **THEN** writing a Terraform buffer SHALL leave its contents unchanged
- **AND** SHALL NOT block the write or raise a repeated error

### Requirement: The terraform CLI is provided by a container, not a host install
`terraform` SHALL be reached through a wrapper script on `$PATH` that runs the pinned `hashicorp/terraform` image, rather than being installed on the host. It is the tool being operated on infrastructure rather than machinery the editor needs to function, so the repository's containers-first principle applies to it.

The wrapper SHALL mount the working directory at **the same path inside the container as outside** (`-v "$PWD:$PWD" -w "$PWD"`), and SHALL drop to the invoking user (`--user`). Both are load-bearing rather than stylistic: a renamed mount makes absolute host paths unresolvable, and `terraform-ls` passes absolute paths; without `--user`, everything `terraform` writes is owned by root on the host.

By contrast `terraform-ls` SHALL run natively. It is a language server — editor machinery in the same category as `lua_ls`, `marksman` and `fsautocomplete`, none of which are containerised. A native server invoking a containerised CLI is exactly why the identity mount is required.

#### Scenario: Absolute paths resolve inside the container
- **WHEN** any caller passes `terraform` an absolute host path
- **THEN** the path SHALL resolve to the same file inside the container
- **AND** a mount that renames the directory SHALL NOT be used

#### Scenario: Files written stay owned by the user
- **WHEN** `terraform` writes to a file or creates `.terraform/`
- **THEN** the result SHALL be owned by the invoking user, not root

#### Scenario: The image is pinned
- **WHEN** the wrapper runs
- **THEN** it SHALL reference a pinned image tag rather than `latest`, so formatting behaviour cannot change without a commit

#### Scenario: Formatting needs no mount
- **WHEN** `conform` formats a buffer
- **THEN** it SHALL invoke `terraform fmt -no-color -` as a stdin/stdout filter
- **AND** the volume mount SHALL NOT be required for that path

