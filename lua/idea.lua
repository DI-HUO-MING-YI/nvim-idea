local M = {}

function M.setup()
	vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
		pattern = { "*.class", "*.java" },
		callback = function(ev)
			require("idea").lsp.fold_imports()
		end,
	})
end

M.lsp = {}
M.lsp.organize_imports = require("lsp.imports").organize_imports
M.lsp.fold_imports = require("lsp.imports").fold_imports

return M
