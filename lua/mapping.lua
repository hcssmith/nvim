local function map(mode, lhs, rhs, opts)
	local options = {noremap = true}
	if opts then options = vim.tbl_extend('force', options, opts) end
	vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

vim.api.nvim_command('command! Mkdir lua mkdir()')

map('i', 'jk', '<Esc>')

map('i', '<A-Up>', '<Esc>:wincmd k<CR>')
map('i', '<A-Down>', '<Esc>:wincmd j<CR>')
map('i', '<A-Left>', '<Esc>:wincmd h<CR>')
map('i', '<A-Right>', '<Esc>:wincmd l<CR>')

map('n', '<A-Up>', ':wincmd k<CR>')
map('n', '<A-Down>', ':wincmd j<CR>')
map('n', '<A-Left>', ':wincmd h<CR>')
map('n', '<A-Right>', ':wincmd l<CR>')
map('n', 't', ':Mkdir<CR>') 
