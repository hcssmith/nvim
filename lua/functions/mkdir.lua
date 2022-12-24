require("functions.isdir")

function Mkdir()
  local dir = vim.api.nvim_buf_get_name(0)
  local d = dir:match("(.*/)")
  if Isdir(d)
    then
      return
  else
    print('Create missing directory? (y)')
    vim.api.nvim_command("let b:conf = nr2char(getchar())")
    local conf = vim.api.nvim_buf_get_var(0, 'conf')
    if conf == 'y' then os.execute('mkdir -p '..d) else return end
  end
end
