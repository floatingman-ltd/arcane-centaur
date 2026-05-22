-- define common options
local opts = {
    noremap = true,      -- non-recursive
    silent = true,       -- do not show message
}
local function desc_opts(desc)
  return vim.tbl_extend("force", opts, { desc = desc })
end

-----------------
-- Normal mode --
-----------------

-- Hint: see `:h vim.map.set()`
-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', desc_opts("Window: move left"))
vim.keymap.set('n', '<C-j>', '<C-w>j', desc_opts("Window: move down"))
vim.keymap.set('n', '<C-k>', '<C-w>k', desc_opts("Window: move up"))
vim.keymap.set('n', '<C-l>', '<C-w>l', desc_opts("Window: move right"))

-- Resize with arrows
-- delta: 2 lines
vim.keymap.set('n', '<C-Up>',    ':resize -2<CR>',          { noremap = true, silent = true, desc = "Window: decrease height" })
vim.keymap.set('n', '<C-Down>',  ':resize +2<CR>',          { noremap = true, silent = true, desc = "Window: increase height" })
vim.keymap.set('n', '<C-Left>',  ':vertical resize -2<CR>', { noremap = true, silent = true, desc = "Window: decrease width" })
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', { noremap = true, silent = true, desc = "Window: increase width" })

-----------------
-- Visual mode --
-----------------

-- Hint: start visual mode with the same area as the previous area and the same mode
vim.keymap.set('v', '<', '<gv', { noremap = true, silent = true, desc = "Indent left" })
vim.keymap.set('v', '>', '>gv', { noremap = true, silent = true, desc = "Indent right" })

-- The following command let's you move up and down the selected code as a block.
-- It even correctly indents the code if, for example, you are moving some code
-- inside an if statement. To use it, simply select the code in visual mode and
-- press Shift + Up or Shift + Down.
vim.keymap.set("v", "<S-Down>", ":m '>+1<CR>gv=gv", { noremap = true, silent = true, desc = "Move block down" })
vim.keymap.set("v", "<S-Up>",   ":m '<-2<CR>gv=gv", { noremap = true, silent = true, desc = "Move block up" })

-- This command is from my VSCode days, and I got used to indent an unindent the
-- code with Tab and Shift + Tab. It simply indents the code and then reselects
-- the previous selection.
vim.keymap.set("v", "<Tab>",   ">gv", { noremap = true, silent = true, desc = "Indent right" })
vim.keymap.set("v", "<S-Tab>", "<gv", { noremap = true, silent = true, desc = "Indent left" })

-- replace code without placing the replaced text in the clipboard
vim.keymap.set("x", "<leader>p", "\"_dP", { noremap = true, silent = true, desc = "Paste without overwriting clipboard" })

-- System-clipboard shortcuts.
-- With clipboard=unnamedplus these mirror plain y/d/p, but the explicit
-- "+register prefix makes the intent unambiguous and works correctly even
-- if the clipboard setting is temporarily changed.
vim.keymap.set({ "n", "v" }, "<leader>y", '"+y',  { noremap = true, silent = true, desc = "Yank to system clipboard" })
vim.keymap.set("n",           "<leader>Y", '"+Y',  { noremap = true, silent = true, desc = "Yank line to system clipboard" })
vim.keymap.set({ "n", "v" }, "<leader>d", '"+d',  { noremap = true, silent = true, desc = "Cut to system clipboard" })
vim.keymap.set("n",           "<leader>p", '"+p',  { noremap = true, silent = true, desc = "Paste from system clipboard (after cursor)" })
vim.keymap.set("n",           "<leader>P", '"+P',  { noremap = true, silent = true, desc = "Paste from system clipboard (before cursor)" })

-- NvimTree
vim.keymap.set("n", "<leader>n", ":NvimTreeOpen<CR>",     { noremap = true, silent = true, desc = "File tree: open" })
vim.keymap.set("n", "<C-n>",    ":NvimTreeOpen<CR>",     { noremap = true, silent = true, desc = "File tree: open" })
vim.keymap.set("n", "<C-t>",    ":NvimTreeToggle<CR>",   { noremap = true, silent = true, desc = "File tree: toggle" })
vim.keymap.set("n", "<C-f>",    ":NvimTreeFindFile<CR>", { noremap = true, silent = true, desc = "File tree: find current file" })

-- Terminal toggle
local term_buf = -1
local function toggle_terminal()
  -- Check if the terminal buffer is currently visible in any window
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == term_buf then
      vim.api.nvim_win_close(win, false)
      return
    end
  end
  -- Open a new split and start/reuse terminal
  vim.cmd("split")
  vim.cmd("resize 15")
  if vim.api.nvim_buf_is_valid(term_buf) then
    vim.api.nvim_set_current_buf(term_buf)
  else
    vim.cmd("term")
    term_buf = vim.api.nvim_get_current_buf()
  end
  vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>t", toggle_terminal, { noremap = true, silent = true, desc = "Toggle terminal split" })
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = true, desc = "Exit terminal insert mode" })

-- Copilot chat
vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
-- Accept only the next word of a Copilot suggestion (instead of the whole completion)
-- <M-f> follows the readline/Emacs "Alt-f = forward word" convention — same semantic intent.
vim.api.nvim_set_keymap("i", "<M-f>", 'copilot#AcceptWord()', { silent = true, expr = true })
vim.api.nvim_set_keymap("n", "<leader>c", "<C-w>h", { noremap = true, silent = true, desc = "Window: focus left" })

-- Copilot CLI
vim.keymap.set({ "n", "v" }, "<leader>gcs", "<cmd>CopilotSuggest<CR>",
  { noremap = true, silent = true, desc = "Copilot CLI: suggest" })
vim.keymap.set({ "n", "v" }, "<leader>gce", "<cmd>CopilotExplain<CR>",
  { noremap = true, silent = true, desc = "Copilot CLI: explain" })

-- Context-aware cheatsheet
vim.keymap.set("n", "<leader>?", function()
  require("config.cheatsheet").open_cheatsheet()
end, { noremap = true, silent = true, desc = "Open context-aware cheatsheet" })

vim.keymap.set("n", "<leader>?g", function()
  require("config.cheatsheet").pick_guide()
end, { noremap = true, silent = true, desc = "Open guide picker" })

-- OpenSpec
vim.keymap.set("n", "<leader>osn", "<cmd>OpenspecNew<CR>",
  { noremap = true, silent = true, desc = "OpenSpec: new change" })
vim.keymap.set("n", "<leader>oss", "<cmd>OpenspecStatus<CR>",
  { noremap = true, silent = true, desc = "OpenSpec: status" })
vim.keymap.set("n", "<leader>osl", "<cmd>OpenspecList<CR>",
  { noremap = true, silent = true, desc = "OpenSpec: list changes" })

-- Folding (nvim-ufo)
vim.keymap.set("n", "zR", function() require("ufo").openAllFolds()  end, { noremap = true, silent = true, desc = "Fold: open all" })
vim.keymap.set("n", "zM", function() require("ufo").closeAllFolds() end, { noremap = true, silent = true, desc = "Fold: close all" })
