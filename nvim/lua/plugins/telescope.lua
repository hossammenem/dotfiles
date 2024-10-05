return {
	'nvim-telescope/telescope.nvim', 
	tag = '0.1.6',
	dependencies = { 'nvim-lua/plenary.nvim', "debugloop/telescope-undo.nvim", },
	config = function() 
		local actions = require('telescope.actions')
		local action_state = require('telescope.actions.state')

		-- this functions doesn't werk
		local close_all_buffers = function(prompt_bufnr)
			local current_picker = action_state.get_current_picker(prompt_bufnr)
			current_picker:delete_selection(function(selection)
				return true 
			end)
			actions.close(prompt_bufnr)
		end

		require("telescope").setup({
			defaults = {
				file_ignore_patterns = { "node_modules" },
				layout_config = {
					horizontal = {
						prompt_position = "bottom",
					},
				},
			},
			pickers = {
				buffers = {
					mappings = {
						i = {
							["<C-d>"] = actions.delete_buffer,
        			["<C-D>"] = close_all_buffers,
						},
						n = {
							["dd"] = actions.delete_buffer,
        			["D"] = close_all_buffers,
						},
					},
				},
			},
			extensions = {
				i = {
					["<cr>"] = require("telescope-undo.actions").yank_additions,
					["<S-cr>"] = require("telescope-undo.actions").yank_deletions,
					["<C-cr>"] = require("telescope-undo.actions").restore,
				},
				n = {
					["y"] = require("telescope-undo.actions").yank_additions,
					["Y"] = require("telescope-undo.actions").yank_deletions,
					["u"] = require("telescope-undo.actions").restore,
				},
			},
		})

		local builtin = require('telescope.builtin')
		vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
		vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
		vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
		vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

		require("telescope").load_extension("undo")
		vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")
	end,
}

