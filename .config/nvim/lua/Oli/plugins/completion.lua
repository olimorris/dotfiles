local has_cmp, cmp = om.safe_require("cmp")
local has_snip, luasnip = om.safe_require("luasnip")
local has_icons, lspkind = om.safe_require("lspkind")

if not has_cmp or not has_snip or not has_icons then
  vim.notify("Could not load completion plugins")
  return
end

cmp.setup({
  completion = {
    completeopt = "menu,menuone,noinsert",
    keyword_pattern = [[\%(-\?\d\+\%(\.\d\+\)\?\|\h\w*\%(-\w*\)*\)]],
    keyword_length = 1,
  },
  experimental = {
    ghost_text = false,
    native_menu = false,
  },
  formatting = {
    format = lspkind.cmp_format({
      mode = "symbol",
      with_text = true,
    }),
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = require(config_namespace .. ".core.mappings").completion_keymaps(),
  sources = { -- Ordered by priority
    { name = "luasnip", max_item_count = 5 },
    { name = "nvim_lsp", max_item_count = 5 },
    {
      name = "buffer",
      max_item_count = 5,
      option = { -- Use all open buffers
        get_bufnrs = function()
          return vim.api.nvim_list_bufs()
        end,
      },
    },
    { name = "nvim_lua" },
    { name = "path" },
  },
  preselect = cmp.PreselectMode.None,
})
