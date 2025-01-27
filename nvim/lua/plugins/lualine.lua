return {
	"nvim-lualine/lualine.nvim",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		local lualine = require("lualine")
		local lazy_status = require("lazy.status") -- to configure lazy pending updates count

		function get_current_folder(str)
			local result = {}
			local pattern = "[^" .. '/' .. "]+"

			for substring in string.gmatch(str, pattern) do
				table.insert(result, substring)
			end

			return result[#result-1]
		end

		-- configure lualine with modified theme
		lualine.setup({
			options = {
				section_separators = { left = '', right = '' },
				component_separators = { left = '', right = '' },
				-- Add this to disable default sections
				disabled_filetypes = { statusline = {}, },
			},
			sections = {
				-- Left sections
				 lualine_a = {'mode'},
				lualine_b = {'branch', 'diff'},
				lualine_c = {'filename'},

				-- Right sections
				lualine_x = {
					{
						lazy_status.updates,
						cond = lazy_status.has_updates,
					},
					{ "diagnostics" },
					{ "filename", path = 2, fmt = function(str) return get_current_folder(str) end },
					{ "location" },
				},
				lualine_y = { {} },  -- File type (e.g. Lua, Python)
				lualine_z = { {"progress"}, },
			},
			-- Add this to override any default inactive sections
			inactive_sections = {
				lualine_a = {},
				lualine_b = {},
				lualine_c = {'filename'},
				lualine_x = {'location'},
				lualine_y = {},
				lualine_z = {}
			},
		})
	end,
}
