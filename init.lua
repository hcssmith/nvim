-- General Settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.signcolumn = "yes"
vim.opt.winborder = "rounded"
vim.opt.path:append('**')



vim.g.mapleader = " "
vim.cmd.colorscheme("habamax")

vim.cmd [[
  highlight Normal guibg=none
  highlight NonText guibg=none
  highlight Normal ctermbg=none
  highlight NonText ctermbg=none
  highlight StatusDefault ctermbg=NONE cterm=NONE
]]

if vim.g.neovide then
  vim.o.guifont = "FiraCode Nerd Font:h10"
  vim.g.neovide_opacity = 0.7
  vim.g.transparency = 0.8
  vim.g.neovide_cursor_trail_size = 0.5
  vim.g.neovide_cursor_short_animation_length = 0.04
end

vim.keymap.set('i', 'jk', '<Esc>')
vim.keymap.set('n', '<leader>ff', ':find ')
vim.keymap.set('n', '<leader>ll', ':make<CR>', { silent = true })
vim.keymap.set('n', ']q', ':cnext<CR>')
vim.keymap.set('n', '[q', ':cprev<CR>')
vim.keymap.set('n', '<leader>qf<CR>', ':copen')

require("lsp")
require("statusline")
