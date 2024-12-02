-- Set the global namespace
_G.om = {}

---Check if a certain feature/version/commit exists in nvim
---@param feature string
---@return boolean
function om.has(feature)
  return vim.fn.has(feature) > 0
end

om.nightly = om.has("nvim-0.11")

---Determine if you're on an external monitor
---@return boolean
function om.on_big_screen()
  return vim.o.columns > 150 and vim.o.lines >= 40
end
