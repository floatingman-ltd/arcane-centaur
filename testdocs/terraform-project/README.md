# terraform-project

Fixture for the `add-terraform-support` validation. It uses no provider, so `terraform init -backend=false` initialises it offline in about a second; a real provider would download tens of megabytes first.

- `envs/dev/main.tf` calls `../../modules/greeting`, above the working directory. This is the case the wrapper's repository-root mount exists for — under a `$PWD`-only mount it fails with `lstat ../../modules: no such file or directory`.
- `envs/dev/badly-formatted.tf` is canonically wrong, so a write proves `terraform fmt` ran.
- `example.hcl` is generic HCL, not Terraform. It exercises `hclfmt` and proves `terraform fmt` is not applied to a filetype it cannot parse.

Once initialised, `module.greeting.greeting` answers in `terraform console`, so the REPL is exercised against real module state and not just arithmetic.
