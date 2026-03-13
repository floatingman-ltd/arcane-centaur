return {
  "tpope/vim-commentary",
  keys = {
    -- <C-_> is the byte most terminals send for Ctrl+/; <C-/> covers terminals
    -- that support the extended keyboard protocol (Kitty, WezTerm, etc.)
    { "<C-_>", ":Commentary<CR>", mode = "n" },
    { "<C-/>", ":Commentary<CR>", mode = "n" },
    { "gcc", mode = "n" },
    { "gc", mode = { "n", "x", "o" } },
  },
}
