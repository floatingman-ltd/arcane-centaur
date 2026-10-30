-- Labels for the which-key popup.
--
-- which-key falls back to a keymap's rhs when it has no `desc`, so plugin maps
-- that don't set one show up as `<Plug>(...)` names or raw Vimscript. The
-- labels below fill those gaps without rebinding anything: a which-key spec's
-- desc only changes what the popup displays.
--
-- Two rules keep labels honest when several plugins share an lhs:
--   * `real = true` hides a label unless a keymap actually exists for it in the
--     current buffer, so filetype-specific labels don't leak into other buffers.
--   * `owned_by` resolves the label lazily and only when the effective keymap
--     (buffer-local first, via maparg) belongs to the plugin being labelled.
--     e.g. iron's global <localleader>sc vs Conjure's buffer-local one in Clojure.

-- Turn `<Plug>(sexp_move_to_next_bracket)` / `<Plug>(unimpaired-move-up)` into
-- `sexp: move to next bracket` / `unimpaired: move up`. Covers vim-sexp and
-- vim-unimpaired, which together account for nearly every map without a desc.
-- It replaces which-key's first default `replace.desc` rule, which only strips
-- the `<Plug>(...)` wrapper, so it falls back to doing the same.
local function plug_label(desc)
  local plugin, action = desc:match("^<Plug>%((%a+)[_-](.+)%)$")
  if plugin then
    return plugin .. ": " .. (action:gsub("[_-]", " "))
  end
  return (desc:gsub("<Plug>%(?(.*)%)?", "%1"))
end

local function owned_by(lhs, mode, needle, text)
  return {
    lhs,
    mode = mode,
    real = true,
    desc = function()
      local m = vim.fn.maparg(lhs, mode, false, true)
      if ((m.desc or "") .. (m.rhs or "")):find(needle, 1, true) then
        return text
      end
    end,
  }
end

-- A group label, chosen by filetype when `label` is a table (`default` covers
-- the rest). If the prefix is itself a keymap in the current buffer, its own
-- desc is shown instead: a group label would otherwise replace it, and the
-- keymap is what runs when the prefix is pressed alone.
local function group(lhs, label, mode)
  mode = mode or "n"
  return {
    lhs,
    mode = mode,
    group = function()
      if next(vim.fn.maparg(lhs, mode, false, true)) then
        return nil
      end
      if type(label) == "table" then
        return label[vim.bo.filetype] or label.default
      end
      return label
    end,
  }
end

local LISP = { "lisp", "clojure", "scheme", "fennel", "janet" }
local function lisp(label, others)
  local t = vim.deepcopy(others or {})
  for _, ft in ipairs(LISP) do
    t[ft] = t[ft] or label
  end
  return t
end

return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    -- which-key rebuilds its options from defaults + opts when it loads, so the
    -- rule must be passed here; inserting into the config table after setup()
    -- is discarded.
    opts = { replace = { desc = { plug_label } } },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)

      wk.add({
        -- Root prefixes, shown when :WhichKey is opened with no keys typed
        { "<leader>", group = "Leader", mode = { "n", "x", "o" } },
        { "[", group = "Previous", mode = { "n", "x", "o" } },
        { "]", group = "Next", mode = { "n", "x", "o" } },
        { "g", group = "Go to / misc", mode = { "n", "x", "o" } },
        group("gr", "LSP"),
        group("gr", "LSP", "x"),
        { "gh", group = "Haskell: GHCi" },
        { "z", group = "Fold / scroll", mode = { "n", "x" } },
        { "=", group = "Indent / reformat" },

        -- Normal-mode groups. A group with no keymaps under it in the current
        -- buffer is not shown.
        group("<leader>?", "Help"),
        group("<leader>a", { markdown = "Avante / table align", default = "Avante" }),
        group("<leader>b", "Debug"),
        group("<leader>e", { haskell = "Haskell: evaluate" }),
        group("<leader>g", "Git"),
        group("<leader>gc", "Claude"),
        group("<leader>h", { haskell = "Git hunks / Hoogle", default = "Git hunks" }),
        group("<leader>i", { markdown = "Table: insert" }),
        group("<leader>o", "OpenSpec"),
        group("<leader>os", "OpenSpec"),
        group("<leader>r", { haskell = "Haskell: REPL / rename", default = "Rename" }),
        group("<leader>x", "Trouble"),

        group("<localleader>c", lisp("Connection", { markdown = "Confluence", default = "REPL" })),
        group("<localleader>ca", "Auto-REPL"),
        group("<localleader>d", lisp("Debugger", { markdown = "PDF export" })),
        group("<localleader>e", "Evaluate"),
        group("<localleader>ec", "Evaluate and comment"),
        group("<localleader>g", "Go to"),
        group("<localleader>j", "Jira"),
        group("<localleader>l", "Log"),
        group("<localleader>m", lisp("Macroexpand", { markdown = "MARP" })),
        group("<localleader>p", "Preview"),
        group("<localleader>r", { clojure = "Refresh namespaces", default = "Reset REPL" }),
        group("<localleader>s", { clojure = "nREPL session", markdown = "Server / REPL", default = "REPL" }),
        group("<localleader>t", { clojure = "Test", default = "dotnet" }),
        group("<localleader>v", "View"),
        group("<localleader>x", "Macroexpand"),
        group("<localleader><lt>", "sexp: put at head"),
        group("<localleader>>", "sexp: put at tail"),
        group("cse", "sexp: surround element"),
        group("ya", "Yank heading as anchor link"),
        group("yf", "Yank heading as file anchor link"),

        -- Visual-mode groups: only the prefixes that hold visual maps. In visual
        -- mode <localleader>e holds vim-sexp's wrap-element maps, not Conjure's.
        group("<leader>a", "Avante", "x"),
        group("<leader>g", "Git", "x"),
        group("<leader>gc", "Claude", "x"),
        group("<localleader>e", "sexp: wrap element", "x"),
        group("<localleader>j", "Jira", "x"),
        group("<localleader>s", "REPL", "x"),
        group("<leader>h", "Git hunks", "x"),
        group("<leader>i", "Select", "x"),
        group("<leader>i", "Select", "o"),

        -- iron.nvim names its maps `iron_repl_*`
        owned_by("<localleader>sc", "n", "iron_repl", "REPL: send motion"),
        owned_by("<localleader>sc", "x", "iron_repl", "REPL: send selection"),
        owned_by("<localleader>sf", "n", "iron_repl", "REPL: send file"),
        owned_by("<localleader>sl", "n", "iron_repl", "REPL: send line"),
        owned_by("<localleader>sp", "n", "iron_repl", "REPL: send paragraph"),
        owned_by("<localleader>s<CR>", "n", "iron_repl", "REPL: send Enter"),
        owned_by("<localleader>si", "n", "iron_repl", "REPL: interrupt"),
        owned_by("<localleader>sq", "n", "iron_repl", "REPL: exit"),
        owned_by("<localleader>cl", "n", "iron_repl", "REPL: clear"),

        -- vim-sexp-mappings-for-regular-people: surround element
        owned_by("cseb", "n", "sexp#wrap", "sexp: surround element with ( )"),
        owned_by("cse(", "n", "sexp#wrap", "sexp: surround element with ( ), cursor at head"),
        owned_by("cse)", "n", "sexp#wrap", "sexp: surround element with ( ), cursor at tail"),
        owned_by("cse[", "n", "sexp#wrap", "sexp: surround element with [ ], cursor at head"),
        owned_by("cse]", "n", "sexp#wrap", "sexp: surround element with [ ], cursor at tail"),
        owned_by("cse{", "n", "sexp#wrap", "sexp: surround element with { }, cursor at head"),
        owned_by("cse}", "n", "sexp#wrap", "sexp: surround element with { }, cursor at tail"),

        -- vim-asciidoctor
        owned_by("[[", "n", "section(1", "AsciiDoc: previous section"),
        owned_by("]]", "n", "section(0", "AsciiDoc: next section"),
        owned_by("[[", "x", "[[m>gv", "AsciiDoc: extend to previous section"),
        owned_by("]]", "x", "]]m>gv", "AsciiDoc: extend to next section"),
        owned_by("gf", "n", "asciidoctor#open_url", "AsciiDoc: open link target"),
        owned_by("gx", "n", "asciidoctor#open_url", "AsciiDoc: open URL in browser"),
        owned_by("ah", "o", "asciidoctor#header", "AsciiDoc: around section"),
        owned_by("ih", "o", "asciidoctor#header", "AsciiDoc: inside section"),
        owned_by("al", "o", "asciidoctor#delimited", "AsciiDoc: around delimited block"),
        owned_by("il", "o", "asciidoctor#delimited", "AsciiDoc: inside delimited block"),
        owned_by("ah", "x", "asciidoctor#header", "AsciiDoc: around section"),
        owned_by("ih", "x", "asciidoctor#header", "AsciiDoc: inside section"),
        owned_by("al", "x", "asciidoctor#delimited", "AsciiDoc: around delimited block"),
        owned_by("il", "x", "asciidoctor#delimited", "AsciiDoc: inside delimited block"),

        -- mkdnflow
        owned_by("[]", "n", "MkdnPrevHeadingSame", "Markdown: previous heading, same level"),
        owned_by("][", "n", "MkdnNextHeadingSame", "Markdown: next heading, same level"),

        -- haskell-tools binds this globally once a Haskell buffer has been opened
        { "ghc", desc = "Haskell: send motion to GHCi", real = true },

        -- vim-fugitive
        owned_by("y<C-G>", "n", "fugitive#Object", "Git: yank object name of current file"),

        -- No-op maps: vim-unimpaired binds <Esc> after its prefixes to cancel
        -- them, and fugitive binds `<Plug>fugitive:` as a marker.
        { "<Plug>fugitive:", hidden = true },
        {
          real = true,
          hidden = true,
          { "[o<Esc>" },
          { "]o<Esc>" },
          { "yo<Esc>" },
          { "<lt>s<Esc>" },
          { ">s<Esc>" },
          { "=s<Esc>" },
        },
      })
    end,
  },
}
