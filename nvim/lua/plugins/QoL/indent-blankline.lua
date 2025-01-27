return {
	"lukas-reineke/indent-blankline.nvim",
	-- main = "ibl",
	opts = {
		indent = {
			char = "│",
			highlight = "IblIndent",
		},
		scope = {
			-- char = "│",
			enabled = false,
			show_start = false,
			show_end = false,
		},
		exclude = {
			filetypes = { "dashboard", "help" } -- Common fix for weird behavior
		}
	},
	config = function(_, opts)
		-- Define distinct highlight groups
		vim.api.nvim_set_hl(0, "IblIndent", { fg = "#4C566A" })

		local hooks = require "ibl.hooks"
		hooks.register(hooks.type.WHITESPACE, hooks.builtin.hide_first_space_indent_level)

		require("ibl").setup(opts)
	end
}
