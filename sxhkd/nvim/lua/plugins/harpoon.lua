return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()

		vim.keymap.set("n", "<leader>ha", function() harpoon:list():append() end)
		vim.keymap.set("n", "<leader>hd", function() harpoon:list():remove() end)

		
		-- Toggle previous & next buffers stored within Harpoon list
		-- just tab and shit+tab
		vim.keymap.set("n", "<S-tab>", function() harpoon:list():prev() end)
		vim.keymap.set("n", "<tab>", function() harpoon:list():next() end)

		local conf = require("telescope.config").values
		local function toggle_telescope(harpoon_files)
			local file_paths = {}
			for _, item in ipairs(harpoon_files.items) do
				table.insert(file_paths, item.value)
			end


				local make_finder = function()
          local paths = {}
          for _, item in ipairs(harpoon_files.items) do
            table.insert(paths, item.value)
          end

          return require("telescope.finders").new_table({ results = paths })
        end

			require("telescope.pickers").new({}, {
				prompt_title = "Harpoon",
				finder = require("telescope.finders").new_table({
					results = file_paths,
				}),
				previewer = conf.file_previewer({}),
				sorter = conf.generic_sorter({}),
				attach_mappings = function(prompt_buffer_number, map)
						map("n", "<C-d>", function() delete_harpoon_mark() end)


						-- map("i", "<c-p>", move_mark_up)
						-- map("n", "<c-p>", move_mark_up)

						-- map("i", "<c-n>", move_mark_down)
						-- map("n", "<c-n>", move_mark_down)
						return true
				end,
			}):find()
		end

		vim.keymap.set("n", "<leader>hl", function() toggle_telescope(harpoon:list()) end,
			{ desc = "Open harpoon window" })
	end,
}
