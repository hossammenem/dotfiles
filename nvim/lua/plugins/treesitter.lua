return {
	'nvim-treesitter/nvim-treesitter',
	config = function () 
		local configs = require("nvim-treesitter.configs")

		configs.setup({
			ensure_installed = { "c", "lua", "go", "cpp", "rust", "javascript", "html", "css", "python", "tsx", "verilog", "haskell", "nix", 'zig', "markdown" },
			highlight = { enable = true, use_languagetree = true },
			indent = { enable = true },
		})
	end,
}
