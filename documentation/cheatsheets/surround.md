# Surround Cheatsheet (vim-surround)

→ Back to [main cheatsheet](index.md)

vim-surround adds keybindings to add, change, and delete surrounding characters (quotes, brackets, tags, etc.) around text objects.

---

## Change surroundings

| Keys | Action | Example |
|---|---|---|
| `cs"'` | Change `"` to `'` | `"hello"` → `'hello'` |
| `cs'<q>` | Change `'` to `<q>` tags | `'hello'` → `<q>hello</q>` |
| `cst"` | Change tag to `"` | `<q>hello</q>` → `"hello"` |

## Delete surroundings

| Keys | Action | Example |
|---|---|---|
| `ds"` | Delete surrounding `"` | `"hello"` → `hello` |
| `dst` | Delete surrounding HTML tag | `<p>hello</p>` → `hello` |

## Add surroundings

Cursor must be inside (or on) the text to surround. `ys` = "you surround".

| Keys | Action | Example |
|---|---|---|
| `ysiw"` | Surround word with `"` | `hello` → `"hello"` |
| `ysiw(` | Surround word with `( )` (with spaces) | `hello` → `( hello )` |
| `ysiw)` | Surround word with `()` (no spaces) | `hello` → `(hello)` |
| `yss)` | Surround entire line with `()` | `hello world` → `(hello world)` |
| `ysit<em>` | Surround inner tag content with `<em>` | `<p>hello</p>` → `<p><em>hello</em></p>` |

## Visual mode

Select text in visual mode, then press `S` followed by the surround character.

| Keys | Action |
|---|---|
| `S"` | Surround selection with `"` |
| `S)` | Surround selection with `()` |
| `S<p>` | Surround selection with `<p></p>` tags |

---

*Plugin loaded via `lua/plugins/init.lua`. No custom configuration — default vim-surround keybindings apply.*
