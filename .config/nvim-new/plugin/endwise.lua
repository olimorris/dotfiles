---Standalone endwise implementation
---Automatically inserts "end" for Lua and Ruby using treesitter
---Adapted from: https://github.com/RRethy/nvim-treesitter-endwise

local M = {}

---Check if a language has endwise queries available
---@param lang string Language name
---@return boolean,TSNode|nil
local function has_endwise_query(lang)
  local ok, query = pcall(vim.treesitter.query.get, lang, "endwise")
  return ok and query ~= nil
end

---Check if cursor is at an endwise position
---@return boolean, string|nil
local function should_insert_end()
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.bo[bufnr].filetype
  local lang = vim.treesitter.language.get_lang(ft)

  if not lang or not has_endwise_query(lang) then
    return false, nil
  end

  local query = vim.treesitter.query.get(lang, "endwise")
  if not query then
    return false, nil
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1] - 1
  local col = cursor[2]

  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then
    return false, nil
  end

  local tree = parser:parse()[1]
  if not tree then
    return false, nil
  end

  local root = tree:root()

  -- Track if we should insert end
  local should_end = false
  local indent_node = nil

  -- Iterate through query matches
  for id, node, _ in query:iter_captures(root, bufnr, 0, -1) do
    local capture_name = query.captures[id]
    local start_row, start_col, end_row, end_col = node:range()

    -- Check if cursor is within or at the end of a @cursor capture
    if capture_name == "cursor" then
      -- Check if cursor is at or near this position
      if row == end_row and col >= start_col and col <= end_col + 1 then
        should_end = true
      elseif row == start_row and col >= start_col and col <= end_col + 1 then
        should_end = true
      end
    end

    -- Track the indent node for proper indentation
    if capture_name == "indent" and should_end then
      local indent_start_row, _ = node:range()
      if indent_start_row <= row then
        indent_node = node
      end
    end
  end

  return should_end, indent_node
end

---Get the indentation string for a node
---@param node TSNode
---@return number
local function get_indent_for_node(node)
  if not node then
    return vim.fn.indent(".")
  end

  local start_row = node:range()
  local line = vim.api.nvim_buf_get_lines(0, start_row, start_row + 1, false)[1]

  if not line then
    return 0
  end

  local indent = line:match("^%s*")
  return #indent
end

---Insert "end" if at an endwise position
local function insert_end()
  local should_end, indent_node = should_insert_end()

  if not should_end then
    return false
  end

  -- Get current indentation
  local base_indent = get_indent_for_node(indent_node)
  local indent_str = string.rep(" ", base_indent)
  local cursor_indent = base_indent + vim.bo.shiftwidth

  -- Insert newline, indented line, and "end"
  local cursor = vim.api.nvim_win_get_cursor(0)
  local row = cursor[1]

  vim.api.nvim_buf_set_lines(0, row, row, false, {
    string.rep(" ", cursor_indent),
    indent_str .. "end",
  })

  vim.api.nvim_win_set_cursor(0, { row + 1, cursor_indent })

  return true
end

---Setup endwise autocmds and keymaps
---@return nil
function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "lua", "ruby" },
    callback = function(args)
      local bufnr = args.buf

      -- <CR> triggers endwise insertion
      vim.keymap.set("i", "<CR>", function()
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "n", false)

        vim.schedule(function()
          -- Check if we're still in insert mode and in the same buffer
          if vim.api.nvim_get_mode().mode:match("^i") and vim.api.nvim_get_current_buf() == bufnr then
            insert_end()
          end
        end)
      end, { buffer = bufnr, desc = "Endwise: Insert end" })
    end,
    group = vim.api.nvim_create_augroup("dotfiles.endwise", { clear = true }),
  })
end

M.setup()

return M
