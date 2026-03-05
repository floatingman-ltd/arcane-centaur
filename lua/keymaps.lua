-- define common options
local opts = {
    noremap = true,      -- non-recursive
    silent = true,       -- do not show message
}

-----------------
-- Normal mode --
-----------------

-- Hint: see `:h vim.map.set()`
-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

-- Resize with arrows
-- delta: 2 lines
vim.keymap.set('n', '<C-Up>', ':resize -2<CR>', opts)
vim.keymap.set('n', '<C-Down>', ':resize +2<CR>', opts)
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', opts)
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', opts)

-----------------
-- Visual mode --
-----------------

-- Hint: start visual mode with the same area as the previous area and the same mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)

-- The following command let's you move up and down the selected code as a block.
-- It even correctly indents the code if, for example, you are moving some code
-- inside an if statement. To use it, simply select the code in visual mode and
-- press Shift + Up or Shift + Down.
vim.keymap.set("v", "< S-Down> ", ":m '> +1< CR> gv=gv")
vim.keymap.set("v", "< S-Up> ", ":m '<-2< CR> gv=gv")

-- This command is from my VSCode days, and I got used to indent an unindent the
-- code with Tab and Shift + Tab. It simply indents the code and then reselects
-- the previous selection.
vim.keymap.set("v", "< Tab> ", "> gv")
vim.keymap.set("v", "< S-Tab> ", "< gv")

-- replace code without placing the replaced text in the clipboard
vim.keymap.set("x", "< leader> p", "\"_dP")

-- NvimTree
vim.keymap.set("n","<leader>n",":NvimTreeOpen<CR>")
vim.keymap.set("n","<C-n>",":NvimTreeOpen<CR>")
vim.keymap.set("n","<C-t>",":NvimTreeToggle<CR>")
vim.keymap.set("n","<C-f>",":NvimTreeFindFile<CR>")

-- Copilot chat
vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
-- Accept only the next word of a Copilot suggestion (instead of the whole completion)
-- <M-f> follows the readline/Emacs "Alt-f = forward word" convention — same semantic intent.
vim.api.nvim_set_keymap("i", "<M-f>", 'copilot#AcceptWord()', { silent = true, expr = true })
vim.api.nvim_set_keymap("n", "<leader>c", "<C-w> h", {noremap = true, silent = true})

-----------------
-- Terminal    --
-----------------

-- Toggle a persistent bottom terminal split with <leader>t.
-- The terminal buffer is reused across toggles so shell history is preserved.
local term_buf = -1
local term_win = -1

local function toggle_terminal()
  -- If the window is still open, close it (hide, don't kill the buffer).
  if vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, false)
    term_win = -1
    return
  end

  -- Open a horizontal split at the bottom, sized to ~30% of the screen.
  vim.cmd("botright split")
  vim.cmd("resize " .. math.floor(vim.o.lines * 0.30))

  if vim.api.nvim_buf_is_valid(term_buf) then
    -- Reuse the existing terminal buffer.
    vim.api.nvim_set_current_buf(term_buf)
  else
    -- First open: start a new terminal.
    vim.cmd("terminal")
    term_buf = vim.api.nvim_get_current_buf()
  end

  term_win = vim.api.nvim_get_current_win()
  vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>t", toggle_terminal, { noremap = true, silent = true, desc = "Toggle terminal split" })

-- Inside the terminal, <C-\><C-n> is the standard Neovim escape to normal mode.
-- Additionally map <leader>t so you can close the panel from inside the terminal.
vim.keymap.set("t", "<leader>t", function()
  vim.cmd("stopinsert")
  toggle_terminal()
end, { noremap = true, silent = true, desc = "Toggle terminal split (from terminal)" })
