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
