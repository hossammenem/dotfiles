local last_file_buffer = nil

local function open_netrw()
    last_file_buffer = vim.fn.bufnr('%')
    vim.cmd('Explore')
end

local function return_to_last_file()
    if last_file_buffer and vim.api.nvim_buf_is_valid(last_file_buffer) then
        vim.api.nvim_set_current_buf(last_file_buffer)
    else
        print("No previous file to return to")
    end
end


vim.keymap.set('n', '<C-n>', function() open_netrw() end, { noremap = true, silent = false })

vim.api.nvim_create_autocmd("filetype", {
  pattern = "netrw",
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
		local opts = { buffer = bufnr, remap = true }

    vim.keymap.set("n", "o", "<CR>", opts)
    vim.keymap.set("n", "af", "%", opts)
    vim.keymap.set("n", "ad", "d", opts)
    vim.keymap.set('n', 'u', '-', opts)
		-- vim.keymap.set('n', '<C-b>', return_to_last_file, opts)
  end,
})
