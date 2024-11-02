local M = {}

function M.ToggleFoldImportsWithLSP()
    local current_pos = vim.api.nvim_win_get_cursor(0)
    local params = { textDocument = vim.lsp.util.make_text_document_params() }

    vim.lsp.buf_request(0, "textDocument/documentSymbol", params, function(err, result, ctx, _)
        if err then
            vim.notify("Error retrieving document symbols: " .. err.message, vim.log.levels.ERROR)
            return
        end

        vim.notify(result, vim.log.levels.INFO)
        if not result or #result == 0 then
            vim.notify("No document symbols found", vim.log.levels.INFO)
            return
        end

        local import_ranges = {}
        for _, symbol in ipairs(result) do
            if symbol.kind == 6 and symbol.name:match("^import") then
                table.insert(import_ranges, symbol.range)
            end
        end

        -- Debug: 打印导入范围
        if #import_ranges == 0 then
            vim.notify("No import statements found", vim.log.levels.INFO)
            return
        end

        for _, range in ipairs(import_ranges) do
            if range and range.start and range["end"] then
                local start_line = range.start.line + 1
                local end_line = range["end"].line + 1
                if vim.fn.foldclosed(start_line) == -1 then
                    vim.cmd("normal! " .. start_line .. "Gv" .. end_line .. "Gzf")
                else
                    vim.cmd("normal! " .. start_line .. "GzR")
                end
            end
        end

        vim.api.nvim_win_set_cursor(0, current_pos)
        vim.notify("Toggled import folds", vim.log.levels.INFO)
    end)
end

function M.setup()
    vim.cmd("command! ToggleFoldImportsWithLSP lua require('nvim-idea').ToggleFoldImportsWithLSP()")
end

return M
