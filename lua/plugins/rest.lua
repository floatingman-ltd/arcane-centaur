return {
  {
    -- Upstream moved from mistweaverco/ to dont-be-evil-company/ (same GitHub
    -- repo id 819582362, same maintainer; the old URL redirects). Pinned to
    -- dcad056, the commit used here since 2026-08: main has since replaced the
    -- engine with a Go daemon and removed Lua/TS scripting (125751e, e60b6d4).
    -- Move the pin only as its own change.
    "dont-be-evil-company/kulala.nvim",
    commit = "dcad056448773ae5b54cadbfdbd188a599cfebd3",
    ft = { "http" },
    -- Keymaps are buffer-local <localleader> maps in after/ftplugin/http.lua.
    opts = {},
  },
}
