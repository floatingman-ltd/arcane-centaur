## ADDED Requirements

### Requirement: The Language Setup matrix lists Terraform
`docs/modules/ROOT/pages/languages/setup.adoc` SHALL carry a Terraform row stating its language server (`terraform-ls`), its formatter (`terraform fmt`), and its treesitter parsers (`terraform`, `hcl`). The row SHALL record that the `terraform` binary is a prerequisite of both the formatter and the server.

#### Scenario: Reader consults the setup matrix
- **WHEN** a reader looks up Terraform in the Language Setup page
- **THEN** the row SHALL name `terraform-ls`, `terraform fmt`, and both parsers
- **AND** SHALL state the `terraform` binary prerequisite

#### Scenario: Guide and cheatsheet are registered in the nav
- **WHEN** a reader browses `nav.adoc`
- **THEN** `languages/terraform.adoc` and `languages/terraform-cheatsheet.adoc` SHALL both appear
- **AND** they SHALL follow the Guide-then-Cheatsheet pairing every other language uses
