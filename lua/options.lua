-- alias'
local global = vim.g
local o = vim.opt

-- Hint: use `:h <option>` to figure out the meaning if needed
o.clipboard = 'unnamedplus'   -- use system clipboard 
o.completeopt = {'menu', 'menuone', 'noselect'}
o.mouse = 'a'                 -- allow the mouse to be used in Nvim

-- Tab
o.tabstop = 2                 -- number of visual spaces per TAB
o.softtabstop = 2             -- number of spacesin tab when editing
o.shiftwidth = 2              -- insert 4 spaces on a tab
o.expandtab = true            -- tabs are spaces, mainly because of python
o.smartindent = true          -- syntax based indents
o.autoindent = true

-- UI config
o.number = true               -- show absolute number
o.relativenumber = true       -- add numbers to each line on the left side
o.cursorline = true           -- highlight cursor line underneath the cursor horizontally
o.splitbelow = true           -- open new vertical split bottom
o.splitright = true           -- open new horizontal splits right
-- o.termguicolors = true        -- enabl 24-bit RGB color in the TUI
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

-- fsharp
global['fsharp#fsautocomplete_command'] = {'dotnet','fsautocomplete','--background-service-enabled'}
-- global['deoplete#enable_at_startup'] = 1

-- pythoin provider
-- global.python3_host_prog = "/usr/bin/python3"
