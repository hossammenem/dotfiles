vim.opt.relativenumber = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2

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

vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10

vim.opt.signcolumn = 'yes'
vim.opt.shortmess:append "sI"

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>nd', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>pd', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', '<C-b>', '<C-^>', { noremap = true, silent = true })


vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- nvchad drived
vim.keymap.set("n", "<C-c>", "<cmd>%y+<CR>")
