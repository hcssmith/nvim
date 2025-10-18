local M = {}

M.file_exists = function(path)
  local found = vim.fs.find(path, { upward = true, type = "file" })
  return #found > 0
end

return M
