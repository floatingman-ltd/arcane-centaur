-- alias'
local global = vim.g
local o = vim.opt

-- disable netrw at the very start of your init.lua
global.loaded_netrw = 1
global.loaded_netrwPlugin = 1

-- Hint: use `:h <option>` to figure out the meaning if needed
o.clipboard = 'unnamedplus'   -- use system clipboard 
o.completeopt = {'menu', 'menuone', 'noselect'}
o.mouse = 'a'                 -- allow the mouse to be used in Nvim

-- Tab
o.tabstop = 2                 -- number of visual spaces per TAB
o.softtabstop = 2             -- number of spaces in tab when editing
o.shiftwidth = 2              -- insert 2 spaces on a tab
o.expandtab = true            -- tabs are spaces, mainly because of python
o.smartindent = true          -- syntax based indents
o.autoindent = true

-- UI config
o.number = true               -- show absolute number
o.relativenumber = true       -- add numbers to each line on the left side
o.cursorline = true           -- highlight cursor line underneath the cursor horizontally
o.splitbelow = true           -- open new vertical split bottom
o.splitright = true           -- open new horizontal splits right
o.termguicolors = true        -- enable 24-bit RGB colour in the TUI
o.showmode = false            -- we are experienced, wo don't need the "-- INSERT --" mode hint

-- Searching
o.incsearch = true            -- search as characters are entered
o.hlsearch = false            -- do not highlight matches
o.ignorecase = true           -- ignore case in searches by default
o.smartcase = true            -- but make it case sensitive if an uppercase is entered

o.scrolloff = 8               -- an 8 line vertical margin
o.signcolumn = "yes"          -- disable the ugly column
o.colorcolumn = ""

-- Spelling
o.spell = true
o.spelllang = "en_ca"

-- open nvim-tree on enable_at_startup
local function open_nvim_tree()

  -- open the tree
  require("nvim-tree.api").tree.open()
end

vim.api.nvim_create_autocmd({ "VimEnter" }, { callback = open_nvim_tree})


-- fsharp
global['fsharp#fsautocomplete_command'] = {'dotnet','fsautocomplete','--background-service-enabled'}
-- global['deoplete#enable_at_startup'] = 1
