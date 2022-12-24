require("functions.create_auto_commands")

local autocmds = {
  onstart = {
    {"BufWinEnter", "*", ":NvimTreeToggle"}
  },
  saving = {
    {"BufWritePre",  "*",  ":lua Mkdir()"}
  }
}

Nvim_create_autocmds(autocmds)
