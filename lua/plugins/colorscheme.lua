-- TokyoNight theme configuration
-- Change `style` to switch variants: "moon" | "storm" | "night" | "day"
local style = "moon"

return {
  "folke/tokyonight.nvim",
  priority = 1000,
  config = function()
    -- GNOME Terminal (and other VTE-based terminals) set VTE_VERSION
    local is_gnome = vim.env.VTE_VERSION ~= nil

    require("tokyonight").setup({
      style = style,
      -- Sync the 16-color ANSI palette with the TokyoNight palette
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        -- GNOME Terminal does not support in-process transparency; use dark
        -- panels and manage terminal background via the terminal profile
        sidebars = "dark",
        floats   = "dark",
      },
      -- Transparency is controlled by the GNOME Terminal profile, not by Neovim
      transparent = false,
      on_highlights = function(hl, _)
        if is_gnome then
          -- GNOME Terminal does not render undercurl; fall back to underline
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
