vim.b.maplocalleader = ","

local term = require("config.terminal")

local function open_in_browser(filepath)
  if term.is_wsl then
    local win_path = vim.fn.system("wslpath -w " .. vim.fn.shellescape(filepath)):gsub("\n", "")
    vim.fn.jobstart(
      { "powershell.exe", "-NoProfile", "-Command", "Start-Process '" .. win_path .. "'" },
      { detach = true }
    )
  else
    vim.fn.jobstart({ "xdg-open", filepath }, { detach = true })
  end
end

-- ,p — convert to HTML via Docker asciidoctor, open in system browser (GUI only)
vim.keymap.set("n", "<localleader>p", function()
  if term.is_console then
    vim.notify(
      "AsciiDoc browser preview requires a graphical environment.\n"
        .. "Use ,pp for an in-terminal glow popup instead.",
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
end, { buffer = true, desc = "AsciiDoc browser preview (Docker asciidoctor → HTML)" })

-- ,pp — convert to Markdown via pandoc, open in glow popup (console + GUI)
vim.keymap.set("n", "<localleader>pp", function()
  if vim.fn.executable("pandoc") ~= 1 then
    vim.notify(
      "pandoc not found — install pandoc for AsciiDoc popup preview.\n"
        .. "Tip: use ,p for the browser preview (requires Docker).",
      vim.log.levels.WARN
    )
    return
  end

  if vim.fn.executable("glow") ~= 1 then
    vim.notify(
      "glow not found — see docs/guides/cli-console-mode.md for installation instructions.",
      vim.log.levels.WARN
    )
    return
  end

  local filepath = vim.fn.expand("%:p")
  local bufnr    = vim.api.nvim_get_current_buf()
  local tmpfile  = "/tmp/asciidoc-glow-" .. bufnr .. ".md"

  vim.fn.system("pandoc -f asciidoc -t commonmark " .. vim.fn.shellescape(filepath) .. " -o " .. vim.fn.shellescape(tmpfile))

  if vim.v.shell_error ~= 0 then
    vim.notify("AsciiDoc popup preview: pandoc conversion failed.", vim.log.levels.ERROR)
    return
  end

  vim.cmd("Glow " .. vim.fn.fnameescape(tmpfile))
end, { buffer = true, desc = "AsciiDoc popup preview (pandoc → glow, console + GUI)" })
