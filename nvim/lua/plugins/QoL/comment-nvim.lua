return {
    'numToStr/Comment.nvim',
    opts = {
        toggler = {
            line = '<leader>/',  -- Toggle line comment
            block = '<leader>?', -- Toggle block comment (consider adding this too)
        },
        opleader = {
            line = '<leader>/',
            block = '<leader>?',
        },
    },
    config = function(_, opts)
        require('Comment').setup(opts)
        -- Additional keybind for visual mode
        vim.keymap.set('v', '<leader>/', '<ESC><cmd>lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>')
    end
}
