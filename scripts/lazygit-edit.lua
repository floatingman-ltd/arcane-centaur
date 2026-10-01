-- Run by LazyGit's os.edit / os.editAtLine / os.openDirInEditor inside the
-- float started by lua/config/lazygit.lua:
--
--   nvim --clean -l scripts/lazygit-edit.lua [--line N] <path>...
--
-- Hands the paths to the Neovim that launched LazyGit ($NVIM) over RPC. They
-- arrive as plain arguments, so no quoting is needed on the way in. `e` on a
-- directory row in LazyGit passes every file under it, hence the list.

local line
local files = {}
local i = 1
while arg[i] do
  if arg[i] == "--line" then
    line = tonumber(arg[i + 1])
    i = i + 2
  else
    -- LazyGit runs this from the repository root; make the path absolute.
    table.insert(files, vim.fn.fnamemodify(arg[i], ":p"))
    i = i + 1
  end
end

if #files == 0 or not vim.env.NVIM then
  io.stderr:write("lazygit-edit: needs at least one path and $NVIM\n")
  os.exit(1)
end

local chan = vim.fn.sockconnect("pipe", vim.env.NVIM, { rpc = true })
vim.rpcrequest(chan, "nvim_exec_lua", "require('config.lazygit').edit(...)", { files, line })
vim.fn.chanclose(chan)
