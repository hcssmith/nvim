local util = require("util")

if util.file_exists("Makefile") then
  vim.bo.makeprg = 'make'
end
