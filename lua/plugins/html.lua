return {
  {
    "turbio/bracey.vim",
    ft = { "html", "css", "javascript" },
    -- `--no-package-lock`: npm otherwise rewrites the tracked server/package-lock.json,
    -- leaving the plugin's git tree dirty so `:Lazy update` fails with local-changes errors.
    build = "npm install --prefix server --no-package-lock",
  },
}
