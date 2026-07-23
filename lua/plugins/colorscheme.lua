-- TokyoNight theme configuration
-- Change `style` to switch variants: "moon" | "storm" | "night" | "day"
local style = "moon"

-- Console (non-truecolor / TTY) selection + cursor colours: a UNIFORM grey
-- background with black text. cterm values use the 16-colour palette
-- (7 = light grey, 0 = black); gui values are a fallback (termguicolors is off
-- in the console). Change these two to retune the console look.
local console_bg_cterm = 7 -- background: light grey
local console_fg_cterm = 0 -- foreground (text): black
local console_bg_gui = "#808080" -- gui fallback background: grey
local console_fg_gui = "#000000" -- gui fallback foreground: black

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
      -- Uniform grey background + black text for the Visual selection (reverse
      -- looked inconsistent — it inverts each cell's syntax colours).
      local sel = ("cterm=NONE gui=NONE ctermbg=%d ctermfg=%d guibg=%s guifg=%s"):format(
        console_bg_cterm,
        console_fg_cterm,
        console_bg_gui,
        console_fg_gui
      )
      vim.cmd("highlight Visual " .. sel)
      -- Leave `guicursor` at Neovim's default (per-mode block/bar). NOTE: on the
      -- bare Linux VT console the block cursor inverts each cell, so over a
      -- *coloured* character the glyph shows through the block. That's a console
      -- rendering limitation — the only way to make the cursor a solid block is a
      -- cursor-colour OSC escape the console mangles into a stray glyph, so we
      -- don't. A real terminal emulator (SSH client) renders the cursor cleanly.
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
        floats = "dark",
      },
      -- Transparency is controlled by the terminal profile, not by Neovim
      transparent = false,
      on_highlights = function(hl, _)
        if not term.has_undercurl then
          -- The terminal does not render undercurl; fall back to underline
          -- for spell and diagnostic highlight groups so they remain visible
          for _, name in ipairs({
            "SpellBad",
            "SpellCap",
            "SpellLocal",
            "SpellRare",
            "DiagnosticUnderlineError",
            "DiagnosticUnderlineWarn",
            "DiagnosticUnderlineInfo",
            "DiagnosticUnderlineHint",
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
