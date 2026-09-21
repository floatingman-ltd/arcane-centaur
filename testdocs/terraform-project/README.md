# terraform-project

Fixture for the `add-terraform-support` validation, deliberately using **no provider**. `terraform init -backend=false` therefore initialises it offline in about a second, where anything naming a real provider would download tens of megabytes before the REPL could answer a single question.

- `envs/dev/main.tf` calls `../../modules/greeting`, which is above the working directory. That is the case the wrapper's repository-root mount exists for — from a `$PWD`-only mount it fails with `lstat ../../modules: no such file or directory`.
- `envs/dev/badly-formatted.tf` is canonically wrong, so a write proves `terraform fmt` ran.
- `example.hcl` is generic HCL, not Terraform. It exercises `hclfmt` and proves `terraform fmt` is not being applied to a filetype it cannot parse.

Once initialised, `module.greeting.greeting` is answerable in `terraform console`, so the REPL is exercised against real module state rather than only stateless arithmetic.
