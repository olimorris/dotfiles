local ok, legendary = pcall(require, "legendary")
if not ok then
  return
end

-- Get the input mark from the user
local function get_input_mark()
  local nr = vim.fn.getchar()
  if type(nr) == "string" then
    nr = string.byte(nr)
  end

  local mark = vim.fn.nr2char(nr)
  -- Check if it's a number from 1-9
  if mark:match("[1-9]") then
    return mark
  end
end

-- Convert a mark number (1-9) to its corresponding character (A-I)
local function mark2char(mark)
  return string.char(mark + 64)
end

legendary.keymaps({
  -- Add Marks ---------------------------------------------------------------
  {
    "m",
    function()
      local mark = get_input_mark()
      if not mark then
        vim.fn.feedkeys("m" .. mark, "n")
        return
      end

      local char = mark2char(mark)
      vim.cmd("mark " .. char)
      vim.notify("Added mark " .. mark, vim.log.levels.INFO, { title = "Bookmark" })
    end,
    description = "Add mark",
  },
  -- Go To Marks ---------------------------------------------------------------
  {
    "'",
    function()
      local mark = get_input_mark()
      if not mark then
        vim.fn.feedkeys("'" .. mark, "n")
        return
      end

      local char = mark2char(mark)
      local mark_pos = vim.api.nvim_get_mark(char, {})
      if mark_pos[1] == 0 then
        return
      end

      -- If the buffer is displayed in a window, switch to it
      local target_buf = mark_pos[3]
      local found_window = false
      local wins = vim.fn.win_findbuf(target_buf)
      if #wins > 0 then
        vim.api.nvim_set_current_win(wins[1])
        found_window = true
      end

      -- Jump to it in the current window
      if not found_window then
        vim.cmd("normal! `" .. char)
      end
    end,
    description = "Go to mark",
  },
  -- Delete Marks -------------------------------------------------------------
  {
    "<LocalLeader>d",
    function()
      local mark = get_input_mark()
      if not mark then
        vim.fn.feedkeys("'" .. mark, "n")
        return
      end
      local char = mark2char(mark)
      vim.cmd("delmarks " .. char)
      vim.notify("Deleted mark " .. mark, vim.log.levels.INFO, { title = "Bookmark" })
    end,
    description = "Delete mark",
  },
})
