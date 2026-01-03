return {
  cmd = { vim.fn.expand("$HOME/.dotnet/tools/csharp-ls") },
  filetypes = { "cs" },

  root_dir = function(bufnr, on_dir)
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    if bufname == "" then
      on_dir(nil)
      return
    end

    local start = vim.fs.dirname(bufname)

    local match = vim.fs.find(
      { "*.sln", "*.csproj", ".git" },
      { upward = true, path = start }
    )[1]

    if match then
      on_dir(vim.fs.dirname(match))
    else
      on_dir(nil)
    end
  end,
  settings = {
    csharp = {
      solution = {
        enable = true
      },
      formatting = {
        enable = false
      }
    }
  }
}
