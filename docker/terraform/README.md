# terraform

The `terraform` CLI, containerised. Two files here, doing opposite things.

## `terraform` — the wrapper

Runs a pinned `hashicorp/terraform` image and is meant to be the `terraform` on `$PATH`:

```sh
ln -s ~/.config/nvim/docker/terraform/terraform ~/.local/bin/terraform
```

`terraform` is the tool being *operated* on infrastructure, so the repository's containers-first rule covers it. `terraform-ls` is not — a language server is editor machinery, in the same category as `lua-language-server` and `fsautocomplete`, and runs natively.

Three details in the wrapper are load-bearing rather than stylistic:

- **Identity mount.** The tree is mounted at the same path inside the container as outside. `terraform-ls` passes absolute host paths, and a renamed mount (`-v "$PWD:/work" -w /work`) makes them unresolvable — measured failing 2026-09-11 with `No file or directory at ../tmp/.../main.tf`.
- **Repository root, not `$PWD`.** A module referenced as `../../modules/thing` is outside the working directory and invisible to a `$PWD`-only mount. Measured 2026-09-21: `terraform init` from `envs/dev` fails with `lstat ../../modules: no such file or directory` under a `$PWD` mount and succeeds under a repository-root mount. Falls back to `$PWD` outside a git repository.
- **`--user`.** Without it everything terraform writes — `.terraform/`, lock files, files formatted in place — is owned by root on the host.

Format-on-save costs roughly 500 ms through this wrapper, against conform's 2000 ms timeout. A native binary would be 10-30 ms. That is the price of the principle and it is recorded as a number so a later reader can weigh it rather than re-derive it.

## `build-hclfmt.sh` — the exception that proves the rule

`hclfmt` formats the `hcl` filetype, which is distinct from `terraform`; `terraform fmt` does not parse generic HCL. conform bundles a definition for it but not the binary, and `hashicorp/hcl` publishes no prebuilt releases, so it has to be compiled.

The compiler runs in a container; the result does not. A formatter the editor spawns on every write belongs on the host next to `stylua`, and containerising the Go toolchain is only a way to avoid installing Go to produce one static binary.

```sh
./docker/terraform/build-hclfmt.sh          # latest
./docker/terraform/build-hclfmt.sh v2.25.0  # pinned
```
