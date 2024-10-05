return {
	'nvim-treesitter/nvim-treesitter',
	config = function () 
		local configs = require("nvim-treesitter.configs")

		configs.setup({
			ensure_installed = { "c", "lua", "go", "cpp", "rust", "javascript", "html", "css", "python", "tsx", "verilog", "haskell"},
			sync_install = false,
			highlight = { enable = true },
			indent = { enable = true },
		})
	end,
}
