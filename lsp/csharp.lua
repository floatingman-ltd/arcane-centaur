local pid = vim.fn.getpid()
local omnisharp_bin = ""
return {
  cmd = { omnisharp_bin, "--languageserver", "--hostPID", tostring(PID)},
  filetypes = {},
  root_markers = {'.git', '*.csproj' },
}
