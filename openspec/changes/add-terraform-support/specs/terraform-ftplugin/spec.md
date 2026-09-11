## ADDED Requirements

### Requirement: Terraform buffers carry filetype-local settings and a REPL binding
`after/ftplugin/terraform.lua` SHALL set the indent width conventional for HCL and SHALL bind `<localleader>s*` maps onto a `terraform console` REPL through iron.nvim, matching the convention F# uses for `dotnet fsi`. Every map SHALL set a `desc` so which-key surfaces it.

#### Scenario: REPL maps follow the existing convention
- **WHEN** the user invokes the REPL maps in a Terraform buffer
- **THEN** a `terraform console` session SHALL start
- **AND** the maps SHALL use the `<localleader>s*` namespace already used for F# and the Lisp family

#### Scenario: Maps are discoverable
- **WHEN** the user presses `<localleader>` in a Terraform buffer
- **THEN** which-key SHALL list the REPL maps with descriptions

### Requirement: The REPL's evaluation model is documented
`terraform console` evaluates expressions against real state, unlike the side-effect-free REPLs this configuration otherwise provides. The guide SHALL state this, so the difference is not discovered by surprise.

#### Scenario: Reader consults the Terraform guide
- **WHEN** a reader looks up the REPL maps
- **THEN** the guide SHALL state that evaluation reads real state
- **AND** SHALL note that an uninitialised directory limits what the console can answer
