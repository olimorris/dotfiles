--[[
  Marks / Bookmarks / Harpoon Replacement in c.60 LOC
  Uses m{1-9} to set marks in a file and then '{1-9} to jump to them

  This is the combination of some awesome work over at:
  https://github.com/neovim/neovim/discussions/33335

  I then borrowed some simplification ideas from:
  https://github.com/LJFRIESE/nvim/blob/master/lua/config/autocmds.lua#L196-L340
--]]

-- Convert a mark number (1-9) to its corresponding character (A-I)
local function mark2char(mark)
  if mark:match("[1-9]") then
    return string.char(mark + 64)
  end
  return mark
end

-- List bookmarks in the session
local function list_marks()
  local snacks = require("snacks")
  return snacks.picker.marks({
    transform = function(item)
      if item.label and item.label:match("^[A-I]$") and item then
        item.label = "" .. string.byte(item.label) - string.byte("A") + 1 .. ""
        return item
      end
      return false
    end,
  })
end

-- Add Marks ------------------------------------------------------------------
vim.keymap.set("n", "m", function()
  local mark = vim.fn.getcharstr()
  local char = mark2char(mark)
  vim.cmd("mark " .. char)
  if mark:match("[1-9]") then
    vim.notify("Added mark " .. mark, vim.log.levels.INFO, { title = "Marks" })
  else
    vim.fn.feedkeys("m" .. mark, "n")
  end
end, { desc = "Add mark" })

-- Go To Marks ----------------------------------------------------------------
vim.keymap.set("n", "'", function()
  local mark = vim.fn.getcharstr()
  local char = mark2char(mark)
  local mark_pos = vim.api.nvim_get_mark(char, {})
  if mark_pos[1] == 0 then
    return vim.notify("No mark at " .. mark, vim.log.levels.WARN, { title = "Marks" })
  end

  vim.fn.feedkeys("'" .. mark2char(mark), "n")
end, { desc = "Go to mark" })

-- List Marks -----------------------------------------------------------------
vim.keymap.set("n", "<Leader>mm", function()
  list_marks()
end, { desc = "List marks" })

-- Delete Marks ---------------------------------------------------------------
vim.keymap.set("n", "<Leader>md", function()
  local mark = vim.fn.getcharstr()
  vim.api.nvim_del_mark(mark2char(mark))
  vim.notify("Deleted mark " .. mark, vim.log.levels.INFO, { title = "Marks" })
end, { desc = "Delete mark" })

vim.keymap.set("n", "<Leader>mD", function()
  vim.cmd("delmarks A-I")
  vim.notify("Deleted all marks", vim.log.levels.INFO, { title = "Marks" })
end, { desc = "Delete all marks" })
