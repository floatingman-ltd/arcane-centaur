vim.b.maplocalleader = ","

local term = require("config.terminal")
local util = require("config.util")
-- Serve the preview over http://127.0.0.1 (not file://) so snap-sandboxed
-- browsers can load it. Backed by Neovim's built-in libuv — no external
-- runtime (python/node). See lua/config/http_preview.lua.
local http_preview = require("config.http_preview")
local PREVIEW_PORT = 8092 -- single-file AsciiDoc preview (,p / ,pp)
local ANTORA_PORT = 8093 -- full Antora site preview (,pa)

local function asciidoc_preview()
  if term.is_console then
    vim.notify("AsciiDoc browser preview requires a graphical environment.", vim.log.levels.WARN)
    return
  end

  if vim.fn.executable("docker") ~= 1 then
    vim.notify(
      "docker not found — install Docker to use AsciiDoc preview.\n"
        .. "See docker/asciidoctor/README.md for details.",
      vim.log.levels.ERROR
    )
    return
  end

  vim.fn.system({ "docker", "info" })
  if vim.v.shell_error ~= 0 then
    vim.notify(
      "Docker is installed but the daemon is not running or not reachable.\n"
        .. "Start Docker and try AsciiDoc preview again.",
      vim.log.levels.ERROR
    )
    return
  end

  local docdir = vim.fn.expand("%:p:h")
  local filename = vim.fn.expand("%:t")
  local bufnr = vim.api.nvim_get_current_buf()
  local servedir = vim.fn.stdpath("cache") .. "/asciidoc-preview"
  local outname = "preview-" .. bufnr .. ".html"
  local outfile = servedir .. "/" .. outname
  vim.fn.mkdir(servedir, "p")

  vim.notify("AsciiDoc preview: converting…", vim.log.levels.INFO)

  vim.fn.jobstart({
    "docker",
    "run",
    "--rm",
    "-v",
    docdir .. ":/documents",
    "-v",
    servedir .. ":" .. servedir,
    "asciidoctor/docker-asciidoctor",
    "asciidoctor",
    "/documents/" .. filename,
    "-o",
    outfile,
  }, {
    on_exit = function(_, code)
      if code ~= 0 then
        vim.schedule(function()
          vim.notify(
            "AsciiDoc preview: conversion failed (exit "
              .. code
              .. ").\n"
              .. "Is Docker running? Check :messages for details.",
            vim.log.levels.ERROR
          )
        end)
        return
      end
      vim.schedule(function()
        -- Serve over http://127.0.0.1 and open that URL (file:// is blocked by
        -- snap-sandboxed browsers on ~/.cache).
        if http_preview.ensure(servedir, PREVIEW_PORT) then
          util.open_url("http://127.0.0.1:" .. PREVIEW_PORT .. "/" .. outname)
        end
      end)
    end,
  })
end

-- ,p / ,pp — convert to HTML via Docker asciidoctor, serve it over http://127.0.0.1
-- and open in the browser. Using http (not file://) avoids snap-browser sandboxing of ~/.cache.
vim.keymap.set(
  "n",
  "<localleader>p",
  asciidoc_preview,
  { buffer = true, desc = "AsciiDoc preview (Docker → HTML, served over http)" }
)
vim.keymap.set(
  "n",
  "<localleader>pp",
  asciidoc_preview,
  { buffer = true, desc = "AsciiDoc preview (Docker → HTML, served over http)" }
)

-- ,pa — full Antora site build + open in browser (reads working tree via antora-playbook-local.yml)
local function antora_preview()
  if term.is_console then
    vim.notify("Antora preview requires a graphical environment.", vim.log.levels.WARN)
    return
  end
  if vim.fn.executable("docker") ~= 1 then
    vim.notify("docker not found — install Docker to use Antora preview.", vim.log.levels.ERROR)
    return
  end

  local repo_root =
    vim.fn.systemlist("git -C " .. vim.fn.shellescape(vim.fn.expand("%:p:h")) .. " rev-parse --show-toplevel")[1]
  if not repo_root or repo_root == "" then
    vim.notify("Antora preview: could not find git repo root.", vim.log.levels.ERROR)
    return
  end

  local site_dir = repo_root .. "/build/site"

  vim.notify("Antora preview: building site…", vim.log.levels.INFO)

  vim.fn.jobstart({
    "docker",
    "run",
    "--rm",
    "-v",
    repo_root .. ":/antora",
    "antora/antora",
    "antora-playbook-local.yml",
  }, {
    on_exit = function(_, code)
      vim.schedule(function()
        if code ~= 0 then
          vim.notify("Antora build failed (exit " .. code .. "). Check :messages for details.", vim.log.levels.ERROR)
          return
        end
        -- Serve the built site over http (same reason as ,p: snap browsers block
        -- file:// under the hidden ~/.config path).
        if http_preview.ensure(site_dir, ANTORA_PORT) then
          vim.notify("Antora preview: build complete — opening browser.", vim.log.levels.INFO)
          util.open_url("http://127.0.0.1:" .. ANTORA_PORT .. "/index.html")
        end
      end)
    end,
  })
end

vim.keymap.set(
  "n",
  "<localleader>pa",
  antora_preview,
  { buffer = true, desc = "Antora full-site preview (Docker → served over http)" }
)
