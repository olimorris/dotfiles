local M = {
  "VonHeikemen/lsp-zero.nvim",
  dependencies = {
    -- LSP Support
    "neovim/nvim-lspconfig",
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",

    -- Autocompletion
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "hrsh7th/cmp-cmdline",
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-nvim-lsp-signature-help",
    "hrsh7th/cmp-nvim-lua",
    "onsails/lspkind.nvim",

    -- Snippets
    "L3MON4D3/LuaSnip",
    "rafamadriz/friendly-snippets",
  },
}

function M.config()
  local legendary_installed, legendary = pcall(require, "legendary")

  local lsp = require("lsp-zero")

  lsp.preset("lsp-compe")

  lsp.set_preferences({
    set_lsp_keymaps = false,
    sign_icons = {
      error = " ",
      warn = " ",
      hint = " ",
      info = " ",
    },
  })

  lsp.ensure_installed({
    "bashls",
    "cssls",
    "dockerls",
    "html",
    "intelephense",
    "jsonls",
    "pyright",
    "solargraph",
    "sumneko_lua",
    "tailwindcss",
    "tsserver",
    "vuels",
    "yamlls",
  })

  lsp.nvim_workspace()

  lsp.on_attach(function(client, bufnr)
    if legendary_installed then
      legendary.keymaps(require(config_namespace .. ".keymaps").lsp_keymaps(client, bufnr))
      legendary.autocmds(require(config_namespace .. ".autocmds").lsp_autocmds(client, bufnr))
      legendary.commands(require(config_namespace .. ".commands").lsp_commands(client, bufnr))
    end
  end)

  lsp.setup()

  vim.diagnostic.config({
    severity_sort = true,
    signs = true,
    underline = false,
    update_in_insert = false,
    virtual_text = false,
    -- virtual_text = {
    --   prefix = "",
    --   spacing = 0,
    -- },
  })
  vim.opt.completeopt = { "menu", "menuone", "noselect" }

  local cmp = require("cmp")
  local luasnip = require("luasnip")
  local cmp_config = lsp.defaults.cmp_config({
    formatting = {
      format = function(...) return require("lspkind").cmp_format({ mode = "symbol_text" })(...) end,
    },
    window = {
      bordered = {
        border = "none",
        winhighlight = "Normal:CmpMenu,FloatBorder:CmpMenu,CursorLine:CmpCursorLine,Search:None",
      },
    },
    mapping = {
      -- go to next placeholder in the snippet
      ["<C-l>"] = cmp.mapping(function(fallback)
        if luasnip.jumpable(1) then
          luasnip.jump(1)
        else
          fallback()
        end
      end, { "i", "s" }),

      -- go to previous placeholder in the snippet
      ["<C-h>"] = cmp.mapping(function(fallback)
        if luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    },
    sources = {
      { name = "luasnip", priority = 100, keyword_length = 2, max_item_count = 8 },
      { name = "nvim_lsp", priority = 90, keyword_length = 3, max_item_count = 8 },
      { name = "path", priority = 20 },
      { name = "buffer", priority = 10, keyword_length = 3, max_item_count = 8 },
      { name = "nvim_lua" },
      { name = "nvim_lsp_signature_help" },
    },
  })

  cmp.setup(cmp_config)

  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = "path" },
    }, {
      {
        name = "cmdline",
        option = {
          ignore_cmds = { "Man", "!" },
        },
      },
    }),
  })

  cmp.setup.cmdline("/", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "buffer" },
    },
  })

  if legendary_installed then legendary.keymaps(require(config_namespace .. ".keymaps").completion_keymaps()) end
end

return M
