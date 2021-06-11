local autocmds = {
  startup = {
    {"VimEnter",  "*",  ":NERDTree"},
    {"VimEnter",  "*",  ":wincmd l"}
  },
  nerdtree = {
    {"bufenter",  "*",  'if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif"'}
  }
}
nvim_create_autocmds(autocmds)
