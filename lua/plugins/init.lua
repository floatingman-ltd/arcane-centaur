return {
  -- general
  "neovim/nvim-lspconfig",
  "tpope/vim-repeat",
  "tpope/vim-unimpaired",

  -- other
  -- "Shougo/neosnippet.vim",
  -- "Shougo/neosnippet-snippets",
  -- "mattn/emmet-vim",
  -- "tpope/vim-fugitive",
  -- "airblade/vim-gitgutter",
  -- "OmniSharp/omnisharp-vim",
  -- "godlygeek/tabular",
  -- "ryanoasis/vim-devicons",
  -- "Xuyuanp/nerdtree-git-plugin",
  -- f-sharp tooling
  -- "autozimu/LanguageClient-neovim", branch = "next", build = "bash install.sh",
  -- "ionide/Ionide-vim",  -- DO NOT ENABLE. Its indent/fsharp.vim is vendored at
  --                         -- indent/fsharp.vim instead; the plugin additionally
  --                         -- registers a second FsAutoComplete LSP client, sets
  --                         -- fdm=syntax (replacing our LSP folds), ships a regex
  --                         -- syntax file, changes commentstring, and binds FSI
  --                         -- keymaps that collide with iron.nvim. See the header
  --                         -- of indent/fsharp.vim.
  -- "junegunn/fzf",
}
