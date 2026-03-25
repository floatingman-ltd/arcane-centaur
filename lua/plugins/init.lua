return {
  -- general
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("config.lsp")
    end,
  },
  "tpope/vim-repeat",
  "tpope/vim-surround",
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
  -- "ionide/Ionide-vim",
  -- "junegunn/fzf",
}
