local M = {}

local function make_code_action_params(from_selection)
	local params
	if from_selection then
		params = vim.lsp.util.make_given_range_params()
	else
		params = vim.lsp.util.make_range_params()
	end
	params.context = {
		diagnostics = {},
	}
	return params
end

local function java_action_organize_imports(_, ctx)
	local offset_encoding = "utf-16"
	local client = require("java.utils.jdtls2")()
	client.request("java/organizeImports", ctx.params, function(err, resp)
		if err then
			print("Error on organize imports: " .. err.message)
			return
		end
		if resp then
			vim.lsp.util.apply_workspace_edit(resp, offset_encoding)
		end
	end, 0)
end

function M.organize_imports()
	java_action_organize_imports(nil, { params = make_code_action_params(false) })
end

function M.fold_imports()
	local buf = vim.api.nvim_get_current_buf()

	-- 使用 Treesitter 查询来匹配 import_declaration 节点
	local lang = vim.bo.filetype
	local parser = vim.treesitter.get_parser(buf, lang)
	local tree = parser:parse()[1]
	local query_string = [[
		(import_declaration) @import
	]]
	local q = vim.treesitter.query.parse(lang, query_string)

	local first_import_start_row = nil
	local last_import_end_row = nil

	for _, match, _ in q:iter_matches(tree:root(), buf, 0, -1) do
		for id, node in pairs(match) do
			if q.captures[id] == "import" then
				local start_row, _, end_row, _ = node:range()
				if not first_import_start_row then
					first_import_start_row = start_row
				end
				last_import_end_row = end_row
			end
		end
	end

	if first_import_start_row and last_import_end_row then
		-- 保存当前光标位置
		local current_pos = vim.api.nvim_win_get_cursor(0)

		-- 只折叠指定范围内的内容
		vim.cmd("keepjumps normal! " .. (first_import_start_row + 1) .. "Gzf" .. (last_import_end_row + 1) .. "G")

		-- 恢复光标位置
		vim.api.nvim_win_set_cursor(0, current_pos)
	end
end

return M
