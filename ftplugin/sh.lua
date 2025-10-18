vim.cmd.compiler("make")

local sh_cmds = vim.api.nvim_create_augroup('ShellAutocommands', { clear = true })

-- Create an autocmd that triggers when the filetype is 'sh'
vim.api.nvim_create_autocmd('FileType', {
  group = sh_cmds,
  pattern = 'sh',
  command = 'compiler make', -- This uses the built-in sh compiler
})

vim.print("running sh.lua")
