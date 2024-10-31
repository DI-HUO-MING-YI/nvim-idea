local M = {}

-- 切换折叠 import 的函数
function M.ToggleFoldImports()
  local current_line = vim.fn.line "." -- 保存当前光标位置
  local in_import_block = false
  local start_line = 0
  local end_line = 0
  local is_folding = false

  -- 跳到文件顶部
  vim.cmd "normal! gg"

  -- 遍历整个文件
  for line_number = 1, vim.fn.line "$" do
    local line_content = vim.fn.getline(line_number):gsub("%s+", "") -- 去除空白字符

    if line_content:match "^import" then
      if not in_import_block then
        in_import_block = true
        start_line = line_number -- 记录 import 语句的起始行
      end
      end_line = line_number -- 更新 import 语句的结束行
    elseif in_import_block and line_content == "" then
      -- 检测到空行，但仍在 import 块内，继续处理
    elseif in_import_block then
      -- 遇到非空行，结束 import 块
      if start_line > 0 and end_line > 0 then
        if vim.fn.foldclosed(start_line) == -1 then
          -- 如果未折叠，则折叠
          vim.cmd("normal! " .. start_line .. "Gv" .. end_line .. "Gzf")
          is_folding = true
        else
          -- 如果已折叠，则展开
          vim.cmd("normal! " .. start_line .. "GzR")
        end
      end
      in_import_block = false -- 重置标志
      start_line = 0
      end_line = 0
    end
  end

  -- 如果文件结束时仍在 import 块内，进行处理
  if in_import_block and start_line > 0 and end_line > 0 then
    if vim.fn.foldclosed(start_line) == -1 then
      -- 如果未折叠，则折叠
      vim.cmd("normal! " .. start_line .. "Gv" .. end_line .. "Gzf")
    else
      -- 如果已折叠，则展开
      vim.cmd("normal! " .. start_line .. "GzR")
    end
  end

  -- 还原光标位置
  vim.fn.cursor(current_line, 0)
end

-- 自动折叠的命令
function M.setup()
	vim.cmd([[
        augroup AutoFoldJavaImports
            autocmd!
            autocmd FileType java lua require('nvim-idea').toggle_fold_imports()
        augroup END
    ]])
	vim.cmd('command! ToggleFoldImports lua require("nvim-idea").toggle_fold_imports()')
end

return M
