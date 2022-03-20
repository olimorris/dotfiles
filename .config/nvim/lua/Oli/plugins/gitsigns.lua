local ok, gitsigns = om.safe_require("gitsigns")
if not ok then
  return
end

gitsigns.setup({
  keymaps = {}, -- Do not use the default mappings
  signs = {
    add = { hl = "GitSignsAdd", text = "+" },
    change = { hl = "GitSignsChange", text = "~" },
    delete = { hl = "GitSignsDelete", text = "-" },
    topdelete = { hl = "GitSignsDelete", text = "-" },
    changedelete = { hl = "GitSignsChange", text = "-" },
  },
})
