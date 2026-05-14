# 01 — Janet in Neovim: Setup

This guide walks you through installing Janet and activating the Neovim toolchain that is already configured in this repository — LSP, REPL, structural editing, formatting, and rainbow delimiters.

> **Series:** 01 Setup ← you are here · [02 First Steps](02-first-steps.md)

---

## 1. Install Janet

Janet has no runtime dependencies and ships as a single binary.

| Platform | Command |
|---|---|
| **Ubuntu / Debian** | Build from source — see [janet-lang.org](https://janet-lang.org/) |
| **Arch Linux** | `sudo pacman -S janet` |
| **macOS** | `brew install janet` |
| **Windows** | Download from [janet-lang.org](https://janet-lang.org/) |

Verify after installing:

```sh
janet -v
```

---

## 2. Install jpm (Janet Package Manager)

`jpm` is the standard package manager for Janet libraries and tools. It is bundled with most Janet installations. Confirm it is available:

```sh
which jpm
```

If it is missing, bootstrap it manually:

```sh
git clone https://github.com/janet-lang/jpm.git
cd jpm
janet bootstrap.janet
```

See [janet-lang/jpm](https://github.com/janet-lang/jpm) for full bootstrap instructions.

---

## 3. Install the LSP Server

`janet-lsp` provides completions, hover documentation, go-to-definition, and inline diagnostics inside Neovim.

```sh
jpm install janet-lsp
```

`jpm` installs binaries to `~/.jpm/bin/`. Add that to your `$PATH` if it is not already there:

```sh
# Add to ~/.bashrc or ~/.zshrc
export PATH="$HOME/.jpm/bin:$PATH"
```

Verify Neovim can find the binary:

```sh
which janet-lsp
```

---

## 4. How the Neovim Plugins Are Wired

Everything is pre-configured. When you open any `.janet` file the following plugins load automatically:

| Plugin | What it does | Config file |
|---|---|---|
| **Conjure** | Spawns a Janet REPL; evaluates code without leaving the editor | `lua/plugins/lisp.lua` |
| **vim-sexp** + **mappings** | Structural editing — slurp, barf, move S-expressions | `lua/plugins/lisp.lua` |
| **nvim-parinfer** | Keeps parentheses balanced as you edit indentation | `lua/plugins/lisp.lua` |
| **rainbow-delimiters.nvim** | Colour-codes matching brackets by nesting depth | `lua/plugins/lisp.lua` |
| **conform.nvim** | Format-on-save (via LSP) + `<leader>f` manual format | `lua/plugins/conform.lua` |
| **janet_lsp** | LSP completions, hover, go-to-definition, diagnostics | `lua/config/lsp.lua` |

Filetype-specific settings (lisp indent, spell off, `localleader = ,`) live in `after/ftplugin/janet.lua`.

---

## 5. Verify the Setup

1. Open (or create) a Janet file:

   ```sh
   nvim hello.janet
   ```

2. Write a minimal expression:

   ```janet
   (print "Hello from Janet!")
   ```

3. Evaluate the buffer with `,eb` — the Conjure log should print `Hello from Janet!`.

4. Check LSP is attached: `:LspInfo` → you should see `janet_lsp` listed as active for the current buffer.

5. Hover over a symbol and press `K` — a documentation popup should appear.

---

## 6. Troubleshooting

| Symptom | Likely cause | Fix |
|---|---|---|
| Conjure never starts a REPL | `janet` not on `$PATH` | `which janet`; install Janet or fix your PATH |
| No completions / hover | `janet-lsp` not found | `which janet-lsp`; add `~/.jpm/bin` to PATH |
| LSP shows as inactive | Server crashed | `:LspLog` for details; check `janet-lsp` binary works standalone |
| Parinfer fights your edits | Working against the paradigm | Edit *indentation*, not parens — parinfer infers parens from indent |

For deeper LSP debugging see `docs/cheatsheets/lsp.md` and run `:LspInfo` / `:LspLog` inside Neovim.

---

**Next:** [02 — First Steps: syntax, data types, and using the tools](02-first-steps.md)
