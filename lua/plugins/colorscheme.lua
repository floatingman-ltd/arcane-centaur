-- TokyoNight theme configuration
-- Change `style` to switch variants: "moon" | "storm" | "night" | "day"
local style = "moon"

return {
  "folke/tokyonight.nvim",
  priority = 1000,
  config = function()
    local term = require("config.terminal")

    -- Non-truecolor console (real TTY / bare SSH): TokyoNight is truecolor-first
    -- and renders poorly there — the Visual selection is invisible and the block
    -- cursor shows artifacts. Keep Neovim's default colorscheme (proper 16-color
    -- highlights), force termguicolors off, make Visual reverse-video (visible
    -- whether or not termguicolors is on), and hand the cursor shape back to the
    -- terminal to avoid guicursor artifacts.
    if not term.has_truecolor then
      vim.o.termguicolors = false
      vim.cmd("highlight Visual cterm=reverse gui=reverse")
      vim.o.guicursor = ""
      return
    end

    require("tokyonight").setup({
      style = style,
      -- Sync the 16-color ANSI palette with the TokyoNight palette
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        -- VTE terminals (GNOME Terminal, etc.) do not support in-process
        -- transparency; use dark panels and manage background via the
        -- terminal profile
        sidebars = "dark",
        floats   = "dark",
      },
      -- Transparency is controlled by the terminal profile, not by Neovim
      transparent = false,
      on_highlights = function(hl, _)
        if not term.has_undercurl then
          -- The terminal does not render undercurl; fall back to underline
          -- for spell and diagnostic highlight groups so they remain visible
          for _, name in ipairs({
            "SpellBad", "SpellCap", "SpellLocal", "SpellRare",
            "DiagnosticUnderlineError", "DiagnosticUnderlineWarn",
            "DiagnosticUnderlineInfo", "DiagnosticUnderlineHint",
          }) do
            if hl[name] then
              hl[name].undercurl = false
              hl[name].underline = true
            end
          end
        end
      end,
    })

    vim.cmd("colorscheme tokyonight-" .. style)
  end,
}
