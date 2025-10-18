vim.keymap.set('n', '<leader>ll', ':make<CR>', { silent = true })
vim.keymap.set('n', ']q', ':cnext<CR>')
vim.keymap.set('n', '[q', ':cprev<CR>')
vim.keymap.set('n', '<leader>qf', function()
  local is_open = false
  for _, win in ipairs(vim.fn.getwininfo()) do
    if win.quickfix == 1 then
      is_open = true
    end
  end
  if is_open then
    vim.cmd('cclose')
  else
    vim.cmd('copen')
  end
end)

