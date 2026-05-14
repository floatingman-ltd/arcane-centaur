vim.b.maplocalleader = ","

local term = require("config.terminal")

local function open_in_browser(filepath)
  if term.is_wsl then
    local win_path = vim.fn.system("wslpath -w " .. vim.fn.shellescape(filepath)):gsub("\n", "")
    vim.fn.jobstart(
      {
        "powershell.exe",
        "-NoProfile",
        "-Command",
        "param($p) Start-Process -FilePath $p",
        win_path,
      },
      { detach = true }
    )
  else
    vim.fn.jobstart({ "xdg-open", filepath }, { detach = true })
  end
end

local function asciidoc_preview()
  if term.is_console then
    vim.notify(
      "AsciiDoc browser preview requires a graphical environment.",
      vim.log.levels.WARN
    )
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

  local docdir  = vim.fn.expand("%:p:h")
  local filename = vim.fn.expand("%:t")
  local bufnr   = vim.api.nvim_get_current_buf()
  local outfile = "/tmp/asciidoc-preview-" .. bufnr .. ".html"

  vim.notify("AsciiDoc preview: converting…", vim.log.levels.INFO)

  vim.fn.jobstart({
    "docker", "run", "--rm",
    "-v", docdir .. ":/documents",
    "-v", "/tmp:/tmp",
    "asciidoctor/docker-asciidoctor",
    "asciidoctor", "/documents/" .. filename,
    "-o", outfile,
  }, {
    on_exit = function(_, code)
      if code ~= 0 then
        vim.schedule(function()
          vim.notify(
            "AsciiDoc preview: conversion failed (exit " .. code .. ").\n"
              .. "Is Docker running? Check :messages for details.",
            vim.log.levels.ERROR
          )
        end)
        return
      end
      vim.schedule(function()
        open_in_browser(outfile)
      end)
    end,
  })
end

-- ,p / ,pp — convert to HTML via Docker asciidoctor, open in system browser (GUI only)
-- Both keymaps trigger the same one-shot convert-and-open flow (no popup equivalent for HTML output).
vim.keymap.set("n", "<localleader>p",  asciidoc_preview, { buffer = true, desc = "AsciiDoc browser preview (Docker asciidoctor → HTML)" })
vim.keymap.set("n", "<localleader>pp", asciidoc_preview, { buffer = true, desc = "AsciiDoc browser preview (Docker asciidoctor → HTML)" })
