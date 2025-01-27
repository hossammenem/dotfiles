--------------
-- setting up Ctrl+n to toggle between newtr and the last opened file buffer
--------------
local last_file_buffer = nil

local function open_netrw()
	last_file_buffer = vim.api.nvim_get_current_buf()
	vim.cmd('Explore')
end

local function return_to_last_file()
	if last_file_buffer and vim.api.nvim_buf_is_valid(last_file_buffer) then
		local netrw_buf = vim.api.nvim_get_current_buf()
		vim.api.nvim_set_current_buf(last_file_buffer)
		vim.api.nvim_buf_delete(netrw_buf, { force = true })
	else
		print("No previous file to return to")
	end
end

local function toggle_netrw()
	if vim.bo.filetype == 'netrw' then
		return_to_last_file()
	else
		open_netrw()
	end
end

vim.keymap.set('n', '<C-e>', toggle_netrw, { noremap = true, silent = false })


--------------
-- some key maps in netwr
--------------
vim.api.nvim_create_autocmd("fileType", {
	pattern = "netrw",
	callback = function()
		local bufnr = vim.api.nvim_get_current_buf()

		local opts = { buffer = bufnr, remap = true }

		vim.keymap.set("n", "o", "<CR>", opts)
		vim.keymap.set('n', 'u', '-', opts)
		vim.keymap.set("n", "af", "%", opts)
		vim.keymap.set("n", "ad", "d", opts)

	end,
})

--------------
-- More QoL
--------------
-- Navigate through opened buffers
vim.keymap.set('n', '<C-n>', function()
	local success, _ = pcall(vim.cmd, 'bnext')
	if not success then
		vim.cmd('bfirst')
	end
end, { desc = 'Next buffer (wrap around)' })

vim.keymap.set('n', '<C-p>', function()
	local success, _ = pcall(vim.cmd, 'bprevious')
	if not success then
		vim.cmd('blast')
	end
end)

vim.keymap.set("n", "<A-D>", "<cmd>%bd|e#<CR>", { desc = "close all buffers, but open the last one for editing "});


vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>') -- remove highlighted search with escape
vim.keymap.set("n", "<C-c>", "<cmd>%y+<CR>")
vim.keymap.set("n", "<C-q>", "<C-i>", { noremap = true })  -- Explicitly restore

--------------
-- Clipboard
--------------
-- Keep clipboard when pasting over visual selection
vim.keymap.set('x', 'p', 'P', { noremap = true, desc = "Disabling pasting in visual mode from copying selection to the clipboard" });

-- Normal mode x/s to blackhole register
vim.keymap.set('n', 'x', '"_x', { noremap = true })
vim.keymap.set('n', 's', '"_s', { noremap = true })

--------------
-- Splits
--------------
vim.keymap.set('n', '<leader>hs', '<Cmd>split<CR>', { desc = 'Horizontal split', noremap = true, silent = true })
vim.keymap.set('n', '<leader>vs', '<Cmd>vsplit<CR>', { desc = 'Vertical split', noremap = true, silent = true })

-- Moving between splits
vim.keymap.set('n', '<A-h>', '<C-w>h', { desc = 'Window left' })
vim.keymap.set('n', '<A-j>', '<C-w>j', { desc = 'Window down' })
vim.keymap.set('n', '<A-k>', '<C-w>k', { desc = 'Window up' })
vim.keymap.set('n', '<A-l>', '<C-w>l', { desc = 'Window right' })

-- Reordering Splits
vim.keymap.set('n', '<A-J>', '<C-w>J')
vim.keymap.set('n', '<A-K>', '<C-w>K')
vim.keymap.set('n', '<A-H>', '<C-w>H')
vim.keymap.set('n', '<A-L>', '<C-w>L')

-- Resizing splits
vim.keymap.set('n', '<C-M-j>', '<Cmd>resize +2<CR>')  -- C-M = Ctrl+Alt
vim.keymap.set('n', '<C-M-k>', '<Cmd>resize -2<CR>')
vim.keymap.set('n', '<C-M-h>', '<Cmd>vertical resize -2<CR>')
vim.keymap.set('n', '<C-M-l>', '<Cmd>vertical resize +2<CR>')
vim.keymap.set("n", "<C-M-f>", function() ToggleMaximizeSplit() end, { desc = "Toggle maximize/restore split" }) -- The function exists in init.lua

--------------
-- Diagnostic keymaps
--------------
vim.keymap.set('n', ']g', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '[g', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>o', function()
	vim.diagnostic.setloclist()  -- First populate the list with diagnostics
	vim.cmd.lopen()             -- Then open the location list window
end)

--------------
-- LSP
--------------
vim.api.nvim_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', {noremap = true, silent = true})
vim.api.nvim_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', {noremap = true, silent = true})
vim.keymap.set('n', 'gf', function()
	vim.cmd("normal! mG")
	vim.cmd("normal! gf")
end, { noremap = true, silent = true })

-- Rename symbol
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = '[R]e[n]ame symbol' })
