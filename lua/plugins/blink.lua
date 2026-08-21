-- One completion keymap, used identically in insert mode and on the command
-- line. The two modes used to be configured separately and drifted: insert
-- accepted with <CR>, while cmdline inherited blink's stock preset and accepted
-- with <C-y>. Muscle memory built in one mode silently failed in the other.
--
-- <CR> is deliberately unbound: it cannot mean "accept" on the command line,
-- where it has to execute, so leaving it as the insert-mode accept key is what
-- made a shared keymap impossible. Enter now always means newline/execute, and
-- <C-y> always means accept.
--
-- <C-n> does double duty as the manual trigger. blink tries a key's commands in
-- order and stops at the first truthy one; `show` returns true only when the
-- menu is closed, so a closed menu opens (highlighting nothing) and an open one
-- falls through to `select_next`. This is also vanilla Vim's meaning for
-- insert-mode <C-n>. It replaces <M-Space>, which could never fire here: this
-- config runs under WSL in a Windows console, which claims Alt-Space for its own
-- system menu. <C-Space> was tried as the replacement and is swallowed the same
-- way, hence a plain Ctrl-plus-letter chord.
local completion_keymap = {
  preset = "none",
  ["<C-n>"] = { "show", "select_next", "fallback" },
  ["<C-p>"] = { "select_prev", "fallback" },
  ["<C-y>"] = { "select_and_accept", "fallback" },
  ["<C-e>"] = { "cancel", "fallback" },
  ["<C-b>"] = { "scroll_documentation_up", "fallback" },
  ["<C-f>"] = { "scroll_documentation_down", "fallback" },
}

return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = {
      "saghen/blink.compat",
      "f3fora/cmp-spell",
    },
    opts = {
      keymap = completion_keymap,
      completion = {
        list = {
          selection = { preselect = false, auto_insert = false },
        },
      },
      sources = {
        default = { "lsp", "buffer", "path", "snippets", "spell" },
        per_filetype = {
          lisp = { "lsp", "buffer", "path", "snippets", "spell", "conjure" },
          clojure = { "lsp", "buffer", "path", "snippets", "spell", "conjure" },
          scheme = { "lsp", "buffer", "path", "snippets", "spell", "conjure" },
          fennel = { "lsp", "buffer", "path", "snippets", "spell", "conjure" },
          janet = { "lsp", "buffer", "path", "snippets", "spell", "conjure" },
        },
        providers = {
          -- cmp-spell bridged via blink.compat; enabled only when spell is on,
          -- min_keyword_length=3 preserves the former keyword_length=3 guard.
          spell = {
            name = "spell",
            module = "blink.compat.source",
            score_offset = -3,
            enabled = function()
              return vim.opt.spell:get()
            end,
            min_keyword_length = 3,
            opts = { keep_all_entries = false },
          },
          -- cmp-conjure bridged via blink.compat; the plugin is declared in
          -- lua/plugins/lisp.lua so it loads alongside Conjure on lisp filetypes.
          conjure = {
            name = "conjure",
            module = "blink.compat.source",
          },
        },
      },
      cmdline = {
        enabled = true,
        -- Deliberately the same table as insert mode, not blink's "cmdline"
        -- preset. cmdline needs an explicit keymap because it would otherwise
        -- inherit preset "none" and have no keys at all; giving it the shared
        -- table rather than a second preset is what keeps the two modes from
        -- drifting apart again. auto_show makes `:` command/path completion
        -- appear without pressing the trigger.
        keymap = completion_keymap,
        completion = { menu = { auto_show = true } },
        sources = function()
          local t = vim.fn.getcmdtype()
          if t == "/" or t == "?" then
            return { "buffer" }
          end
          if t == ":" then
            return { "cmdline", "path" }
          end
          return {}
        end,
      },
    },
  },
}
