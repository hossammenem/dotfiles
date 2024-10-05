return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		local lspconfig = require("lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local capabilities = cmp_nvim_lsp.default_capabilities()

		lspconfig['tsserver'].setup {
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = {"typescript", "javascript", "typescript.tsx", "javascript.jsx", "typescriptreact", "javascriptreact"}
		}

		lspconfig['html'].setup{
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = {"html", "typescript.tsx", "javascript.jsx", "typescriptreact", "javascriptreact"}
		}

		lspconfig['cssls'].setup{
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = {"css"}
		}

		lspconfig['tailwindcss'].setup {
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = {"html", "typescript.tsx", "javascript.jsx", "typescriptreact", "javascriptreact"}
		}

		lspconfig['emmet_ls'].setup {
			on_attach = on_attach,
			capabilities = capabilities,
			filetypes = {"html", "typescript.tsx", "javascript.jsx", "typescriptreact", "javascriptreact"}
		}
	end,
}
