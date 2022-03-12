local ok, cmp = om.safe_require("cmp")
if not ok then
  return
end

local lspkind = require("lspkind")
local luasnip = require("luasnip")

cmp.setup({
  snippet = function()
    if luasnip then
      return {
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      }
    end
  end,
  experimental = { ghost_text = false },
  documentation = {
    border = "single",
    winhighlight = "Normal:CmpDocumentation,FloatBorder:CmpDocumentationBorder",
    -- maxwidth = require('core.utils').fix_width(0, 0.9),
    -- maxheight = require('core.utils').fix_height(0, 0.9)
  },
  formatting = {
    deprecated = true, -- Show deprecated items
    format = lspkind.cmp_format({
      mode = "symbol", -- show only symbol annotations
      maxwidth = 50,
    }),
  },
  mapping = {
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    -- ["<C-space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.close(),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = false, -- hitting <CR> when nothing is selected, does nothing
    }),
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip and luasnip.expand_or_jumpable() then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-expand-or-jump", true, true, true), "")
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip and luasnip.jumpable(-1) then
        vim.fn.feedkeys(vim.api.nvim_replace_termcodes("<Plug>luasnip-jump-prev", true, true, true), "")
      else
        fallback()
      end
    end, { "i", "s" }),
  },
  sources = { -- Ordered by priority
    { name = "nvim_lsp", max_item_count = 5 },
    { name = "luasnip", max_item_count = 5 },
    {
      name = "buffer",
      option = { -- Use all open buffers
        get_bufnrs = function()
          return vim.api.nvim_list_bufs()
        end,
      },
    },
    { name = "nvim_lua" },
    { name = "path" },
  },
})
