return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { 
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()

		local conf = require("telescope.config").values
		local state = require("telescope.actions.state")
		local actions = require("telescope.actions")
		local finder = require("telescope.finders")


        local function create_finder(list)
            return finder.new_table({
                results = list.items,
                entry_maker = function(entry)
                    return {
                        value = entry.value,
                        display = entry.value:gsub("^" .. vim.loop.cwd(), "."),
                        ordinal = entry.value,
                        -- Add path for fzf compatibility
                        path = entry.value,
                    }
                end,
            })
        end

        local function toggle_telescope(list)
            local picker = require("telescope.pickers").new({}, {
                prompt_title = "Harpoon",
                finder = create_finder(list),
                previewer = conf.file_previewer({}),
                sorter = conf.generic_sorter({}),
                attach_mappings = function(prompt_bufnr, map)
                    local function refresh_picker()
                        local current_picker = state.get_current_picker(prompt_bufnr)
                        current_picker:refresh(create_finder(list), { reset_prompt = true })
                    end

                    -- Delete entry
                    map("i", "<C-d>", function()
                        local selection = state.get_selected_entry()
                        if selection then
                            table.remove(list.items, selection.index)
                            refresh_picker()
                        end
                    end)

                    -- Move entry up
                    map("i", "<C-p>", function()
                        local selection = state.get_selected_entry()
                        if selection and selection.index > 1 then
                            local idx = selection.index
                            local item = list.items[idx]
                            table.remove(list.items, idx)
                            table.insert(list.items, idx - 1, item)
                            refresh_picker()
                            actions.move_selection_previous(prompt_bufnr)
                        end
                    end)

                    -- Move entry down
                    map("i", "<C-n>", function()
                        local selection = state.get_selected_entry()
                        if selection and selection.index < #list.items then
                            local idx = selection.index
                            local item = list.items[idx]
                            table.remove(list.items, idx)
                            table.insert(list.items, idx + 1, item)
                            refresh_picker()
                            actions.move_selection_next(prompt_bufnr)
                        end
                    end)

                    return true
                end
            }):find()
        end

		-- Key mappings
		vim.keymap.set("n", "<leader>l", function() toggle_telescope(harpoon:list()) end)
		vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
		vim.keymap.set("n", "<leader>d", function() harpoon:list():remove() end)

		vim.keymap.set("n", "<S-tab>", function() harpoon:list():prev() end)
		vim.keymap.set("n", "<tab>", function() harpoon:list():next() end)

		vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end)
		vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end)
		vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end)
		vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end)

	end,
}
