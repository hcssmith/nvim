require("functions.create_auto_commands")

local autocmds = {
  saving = {
    {"BufWritePre",  "*",  ":lua Mkdir()"}
  }
}

Nvim_create_autocmds(autocmds)
