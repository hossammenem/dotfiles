vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

-- make sure you have xclip ( :echo has('clipboard') )
vim.opt.clipboard = 'unnamedplus' 
vim.opt.showmode = false
vim.opt.mouse = 'a'
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.laststatus = 2
vim.opt.showmode = false

vim.opt.list = false
-- vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10

vim.opt.signcolumn = 'yes'
vim.opt.shortmess:append "sI"

vim.opt.hlsearch = true
vim.g.netrw_liststyle = 0

vim.opt.splitright = true
vim.opt.splitbelow = true
