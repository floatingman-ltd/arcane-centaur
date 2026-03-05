-- TokyoNight theme configuration
-- Change `style` to switch variants: "moon" | "storm" | "night" | "day"
local style = "moon"

return {
  "folke/tokyonight.nvim",
  priority = 1000,
  config = function()
    -- Detect kitty terminal for optimised rendering
    local is_kitty = vim.env.TERM == "xterm-kitty" or vim.env.KITTY_WINDOW_ID ~= nil

    require("tokyonight").setup({
      style = style,
      -- Kitty supports true color and undercurl natively; enable the extras
      terminal_colors = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
        functions = {},
        variables = {},
        -- Use background transparency when running inside kitty so the
        -- terminal's own background / blur settings show through
        sidebars = is_kitty and "transparent" or "dark",
        floats   = is_kitty and "transparent" or "dark",
      },
      -- Let kitty handle the background so blurring / background images work
      transparent = is_kitty,
      -- Undercurl is fully supported by kitty
      on_highlights = function(hl, _)
        if is_kitty then
          -- Ensure undercurl is explicitly enabled for spell/diagnostic groups in kitty
          for _, name in ipairs({ "SpellBad", "SpellCap", "SpellLocal", "SpellRare" }) do
            if hl[name] then
              hl[name].undercurl = true
            end
          end
        end
      end,
    })

    vim.cmd("colorscheme tokyonight-" .. style)
  end,
}
