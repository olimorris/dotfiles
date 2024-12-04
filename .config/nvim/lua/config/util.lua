-- Set the global namespace
_G.om = {}

om.nightly = om.has("nvim-0.11")
om.on_personal = vim.fn.getenv("USER") == "Oli"

---Check if a certain feature/version/commit exists in nvim
---@param feature string
---@return boolean
function om.has(feature)
  return vim.fn.has(feature) > 0
end

---Determine if you're on an external monitor
---@return boolean
function om.on_big_screen()
  return vim.o.columns > 150 and vim.o.lines >= 40
end
