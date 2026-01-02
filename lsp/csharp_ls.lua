return {
  cmd = { "csharp-ls" },
  filetypes = { "cs" },

  root_dir = function(fname)
    local dir = vim.fs.dirname(fname)

    return vim.fs.find(
      { "*.sln", "*.csproj", ".git" },
      { upward = true, path = dir }
    )[1]
  end,
  settings = {
    csharp = {
      solution = {
        enable = true
      },
      formatting = {
        enable = true
      }
    }
  }
}
