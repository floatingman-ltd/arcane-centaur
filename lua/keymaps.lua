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

-- NERDTree
vim.keymap.set("n","<leader>n",":NERDTreeFocus<CR>")
vim.keymap.set("n","<C-n>",":NERDTree<CR>")
vim.keymap.set("n","<C-t>",":NERDTreeToggle<CR>")
vim.keymap.set("n","<C-f>",":NERDTreeFind<CR>")

