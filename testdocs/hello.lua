-- hello world in Lua
-- open this file in Neovim to test code folding:
--   za  toggle fold under cursor
--   zM  close all folds
--   zR  open all folds

local M = {}

function M.greet(name)
  if name == nil or name == "" then
    return "Hello, World!"
  end
  return "Hello, " .. name .. "!"
end

function M.farewell(name)
  if name == nil or name == "" then
    return "Goodbye, World!"
  end
  return "Goodbye, " .. name .. "!"
end

local function shout(message)
  return string.upper(message) .. "!!!"
end

function M.greet_loudly(name)
  local greeting = M.greet(name)
  return shout(greeting)
end

function M.run()
  print(M.greet("Neovim"))
  print(M.farewell("Neovim"))
  print(M.greet_loudly("World"))
end

M.run()

return M
