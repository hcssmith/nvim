function mkdir()
  local dir = vim.api.nvim_buf_get_name(0)
  d = dir:match("(.*/)")
  os.execute('mkdir -p '..d)
end
vim.api.nvim_command('command! Mkdir lua mkdir()')


--https://teukka.tech/luanvim.html
function nvim_create_autocmds(definitions)
  for group_name, definition in pairs(definitions) do
    vim.api.nvim_command('augroup '..group_name)
    vim.api.nvim_command('autocmd!')
    for _, def in ipairs(definition) do
      local command = table.concat(vim.tbl_flatten{'autocmd', def}, ' ')
      vim.api.nvim_command(command)
    end
    vim.api.nvim_command('augroup END')
  end
end

