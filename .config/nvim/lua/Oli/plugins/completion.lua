local has_cmp, cmp = om.safe_require("cmp")
local has_snip, luasnip = om.safe_require("luasnip")

if not has_cmp or not has_snip then
  vim.notify("Could not load completion plugins")
  return
end

local icons = {
  Text = "",
  Method = "",
  Function = "",
  Constructor = "⌘",
  Copilot = "",
  Field = "ﰠ",
  Variable = "",
  Class = "ﴯ",
  Interface = "",
  Module = "",
  Property = "ﰠ",
  Unit = "塞",
  Value = "",
  Enum = "",
  Keyword = "廓",
  Snippet = "",
  Color = "",
  File = "",
  Reference = "",
  Folder = "",
  EnumMember = "",
  Constant = "",
  Struct = "פּ",
  Event = "",
  Operator = "",
  TypeParameter = "",
}

local cmp_config = {
  completion = {
    completeopt = "menu,menuone,noinsert",
  },
  preselect = cmp.PreselectMode.None,
  experimental = {
    ghost_text = false,
    native_menu = false,
  },
  formatting = {
    fields = { "kind", "abbr", "menu" },
    format = function(_, vim_item)
      vim_item.menu = vim_item.kind
      vim_item.kind = icons[vim_item.kind]

      return vim_item
    end,
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = require(config_namespace .. ".core.mappings").completion_keymaps(),
}

cmp.setup(vim.tbl_deep_extend("force", cmp_config, {
  sources = {
    { name = "luasnip", priority = 100 },
    { name = "nvim_lsp", priority = 90 },
    { name = "nvim_lsp_signature_help" },
    { name = "nvim_lua", priority = 90 },
    { name = "copilot", priority = 80 },
    { name = "path", priority = 5 },
  },
}))

cmp.setup.cmdline(":", vim.tbl_deep_extend("force", cmp_config, { sources = { { name = "cmdline" } } }))
cmp.setup.cmdline("/", vim.tbl_deep_extend("force", cmp_config, { sources = { { name = "buffer" } } }))
