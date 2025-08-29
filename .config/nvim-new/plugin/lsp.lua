local icons = {
  [vim.diagnostic.severity.ERROR] = "",
  [vim.diagnostic.severity.WARN] = "",
  [vim.diagnostic.severity.INFO] = "",
  [vim.diagnostic.severity.HINT] = "",
}

require("mason").setup()

vim.lsp.enable({
  "jsonls",
  "lua_ls",
})
vim.diagnostic.config({
  severity_sort = true,
  signs = {
    text = icons,
  },
  underline = false,
  update_in_insert = true,
  virtual_text = false,
})

require("conform").setup({
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
  formatters_by_ft = {
    css = { "prettier" },
    html = { "prettier" },
    javascript = { "prettier" },
    json = { "prettier" },
    lua = { "stylua" },
    -- python = { "isort", "black" },
    ruby = { "rubocop" },
  },
})

require("ufo").setup()
local capabilities = vim.lsp.protocol.make_client_capabilities()
local has_blink, blink = pcall(require, "blink.cmp")
capabilities = vim.tbl_deep_extend("force", capabilities, has_blink and blink.get_lsp_capabilities() or {}, {
  textDocument = {
    foldingRange = {
      dynamicRegistration = false,
      lineFoldingOnly = true,
    },
  },
})

require("troublesum").setup({
  enabled = function()
    local ft = vim.bo.filetype
    return ft ~= "lazy" and ft ~= "mason" and ft ~= "codecompanion"
  end,
  severity_format = vim
    .iter(ipairs(icons))
    :map(function(_, icon)
      return icon
    end)
    :totable(),
})
