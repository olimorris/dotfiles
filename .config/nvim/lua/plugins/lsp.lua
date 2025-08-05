local icons = {
  [vim.diagnostic.severity.ERROR] = "",
  [vim.diagnostic.severity.WARN] = "",
  [vim.diagnostic.severity.INFO] = "",
  [vim.diagnostic.severity.HINT] = "",
}

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
    python = { "isort", "black" },
    ruby = { "rubocop" },
  },
})
require("blink.cmp").setup({
  cmdline = { sources = { "cmdline" } },
  completion = {
    accept = {
      auto_brackets = {
        enabled = true,
      },
    },
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 250,
      treesitter_highlighting = true,
      window = { border = "rounded" },
    },
    list = {
      selection = {
        preselect = false,
      },
    },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    providers = {
      lsp = {
        min_keyword_length = 2, -- Number of characters to trigger porvider
        score_offset = 0, -- Boost/penalize the score of the items
      },
      path = {
        min_keyword_length = 0,
      },
      snippets = {
        min_keyword_length = 1,
        opts = {
          search_paths = { "~/.config/snippets" },
        },
      },
      buffer = {
        min_keyword_length = 5,
        max_items = 5,
      },
    },
  },
  keymap = {
    ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
    ["<C-e>"] = { "hide", "fallback" },
    ["<CR>"] = { "accept", "fallback" },

    ["<Tab>"] = {
      function(cmp)
        return cmp.select_next()
      end,
      "snippet_forward",
      "fallback",
    },
    ["<S-Tab>"] = {
      function(cmp)
        return cmp.select_prev()
      end,
      "snippet_backward",
      "fallback",
    },

    ["<Up>"] = { "select_prev", "fallback" },
    ["<Down>"] = { "select_next", "fallback" },
    ["<C-p>"] = { "select_prev", "fallback" },
    ["<C-n>"] = { "select_next", "fallback" },
    ["<C-up>"] = { "scroll_documentation_up", "fallback" },
    ["<C-down>"] = { "scroll_documentation_down", "fallback" },
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

om.create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("dotfiles.lsp-attach", { clear = false }),
  desc = "LSP actions",
  callback = function(event)
    local bufnr = event.buf

    ---Shortcut function to map keys
    ---@param keys string
    ---@param desc string
    ---@param func function|string
    ---@param mode? string|table
    ---@return nil
    local map = function(keys, desc, func, mode)
      mode = mode or "n"
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
    end

    map("gf", "Find Diagnostics", function()
      Snacks.picker.diagnostics_buffer()
    end)
    map("gq", "Format", function()
      require("conform").format({ async = true, bufnr = bufnr, lsp_format = "fallback" })
    end)
    map("gr", "Find References", function()
      Snacks.picker.lsp_references()
    end)
    map("gd", "Go to definition", function()
      Snacks.picker.lsp_definitions()
    end)
    map(
      "gl",
      "Show Line Diagnostics",
      "<cmd>lua vim.diagnostic.open_float(0, { border = 'single', source = 'always' })<CR>"
    )
    map("K", "Show hover information", "<cmd>lua vim.lsp.buf.hover<CR>")
    map("gI", "Go to [I]mplementation", function()
      Snacks.picker.lsp_implementations()
    end)
    map("gy", "Go to T[y]pe Definition", function()
      Snacks.picker.lsp_type_definitions()
    end)
    map("ga", "[G]oto Code [A]ction", vim.lsp.buf.code_action, { "n", "x" })
    map("grn", "[R]e[n]ame", vim.lsp.buf.rename)
    map("[", "Go to previous diagnostic item", function()
      vim.diagnostic.jump({ count = -1, float = true })
    end)
    map("]", "Go to next diagnostic item", function()
      vim.diagnostic.jump({ count = 1, float = true })
    end)

    local client = vim.lsp.get_client_by_id(event.data.client_id)

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
      local highlight_augroup = vim.api.nvim_create_augroup("dotfiles.lsp-highlight", { clear = false })

      om.create_autocmd({ "CursorHold", "CursorHoldI" }, {
        buffer = event.buf,
        callback = vim.lsp.buf.document_highlight,
        group = highlight_augroup,
      })
      om.create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        buffer = event.buf,
        callback = vim.lsp.buf.clear_references,
        group = highlight_augroup,
      })
      om.create_autocmd("LspDetach", {
        group = vim.api.nvim_create_augroup("dotfiles.lsp-detach", { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = "dotfiles.lsp-highlight", buffer = event2.buf })
        end,
      })
    end
  end,
})

require("mason").setup({
  ui = {
    border = "single",
    width = 0.9,
  },
})
require("mason-lspconfig").setup({
  ensure_installed = {
    "intelephense",
    "jdtls",
    "jsonls",
    "lua_ls",
    "pyright",
    "ruby_lsp",
    "vuels",
    "yamlls",
  },
  handlers = {
    -- this first function is the "default handler"
    -- it applies to every language server without a "custom handler"
    function(ls)
      require("lspconfig")[ls].setup({
        capabilities = capabilities,
      })
    end,
  },
})

vim.diagnostic.config({
  severity_sort = true,
  signs = {
    text = icons,
  },
  underline = false,
  update_in_insert = true,
  virtual_text = false,
  -- virtual_text = {
  --   prefix = "",
  --   spacing = 0,
  -- },
})
