return {
	'nvim-telescope/telescope.nvim', 
	tag = '0.1.6',
	dependencies = { 'nvim-lua/plenary.nvim', "debugloop/telescope-undo.nvim", 
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" } },
	config = function() 
		local actions = require('telescope.actions')
		local action_state = require('telescope.actions.state')

		local pickers = require('telescope.pickers')
		local finders = require('telescope.finders')  -- Added missing finders requirement
		local conf = require('telescope.config').values
		local scandir = require('plenary.scandir')
		
		-- Store the initial working directory
		local initial_cwd = vim.loop.cwd()

		local function get_directory_list()
			-- Use plenary's fast scanner with depth control
			return scandir.scan_dir(initial_cwd, {
				hidden = false,
				add_dirs = true,
				only_dirs = true,
				respect_gitignore = true,
				depth = 4,  -- Adjust this for deeper scanning
				silent = true,
			})
		end

		---------------
		-- Custom Directory Picker
		---------------
		local function directory_picker()
			pickers.new(opts, {
				prompt_title = 'Browse Directories',
				finder = finders.new_dynamic({
					fn = function()
						return get_directory_list(opts)
					end,
					entry_maker = function(entry)
						return {
							value = entry,
							display = vim.fn.fnamemodify(entry, ':~:.'),
							ordinal = entry,
						}
					end
				}),
				sorter = conf.generic_sorter(),

				attach_mappings = function(prompt_bufnr, map)
					-- Custom selection handler
					local on_select = function()
						local selection = action_state.get_selected_entry()
						actions.close(prompt_bufnr)

						if selection then
							-- Open in netrw without changing the actual working directory
							vim.cmd('edit ' .. vim.fn.fnameescape(selection.value))
						end
					end

					-- Override default enter key
					map('i', '<CR>', on_select)
					map('n', '<CR>', on_select)

					-- Keep default Telescope mappings
					return true
				end,
			}):find()
		end

		require("telescope").setup({
			defaults = {
				file_ignore_patterns = { "node_modules" },
				layout_config = {
					horizontal = {
						prompt_position = "bottom",
					},
				},
				mappings = {
					i = {
						["<Tab>"] = require('telescope.actions').move_selection_previous,
						["<S-Tab>"] = require('telescope.actions').move_selection_next
					},
				}
			},
			extensions = {
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
				harpoon = {
					i = {
						["<C-d>"] = require("harpoon"):list():remove(),
					}
				},
				undo = {
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
				}
			},
		})

		-- Builtin keymaps
		local builtin = require('telescope.builtin')

		vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
		vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
		vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
		vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
		vim.keymap.set('n', '<leader>fd', directory_picker, { desc = 'Find project directories' })

		-- Loading extensions
		require("telescope").load_extension("undo")
		vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>")

		require('telescope').load_extension('fzf')
	end,
}

