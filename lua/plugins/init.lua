return { 
  -- copilot
  -- Change vim.g.copilot_model to switch the inline-completion model,
  -- e.g. "gpt-4o", "gpt-4.1", or "claude-sonnet-4-5".
  {
    "github/copilot.vim",
    config = function()
      vim.g.copilot_model = "gpt-4o"
    end,
  },
  -- general
  "tpope/vim-repeat",
  "tpope/vim-sensible",
  "tpope/vim-surround",
  "tpope/vim-unimpaired",
  "vim-airline/vim-airline",
  -- treesitter
  {
    "nvim-treesitter/nvim-treesitter", 
    build = ":TSUpdate",
    opts = {
      ensure_installed = {"lisp", "clojure", "scheme", "lua", "fsharp", "vim"},
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    },
  },
  {"neovim/nvim-lspconfig"},
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
    },
  },

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
