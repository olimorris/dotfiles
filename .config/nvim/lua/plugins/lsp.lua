local lsp_buffers = {}

local icons = {
  [vim.diagnostic.severity.ERROR] = "",
  [vim.diagnostic.severity.WARN] = "",
  [vim.diagnostic.severity.INFO] = "",
  [vim.diagnostic.severity.HINT] = "",
}

return {
  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependences = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
    },
    event = "InsertEnter",
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        sources = {
          { name = "luasnip", priority = 100, max_item_count = 5 },
          -- { name = "copilot", priority = 90, max_item_count = 5 },
          { name = "nvim_lsp", priority = 90 },
          { name = "path", priority = 20 },
          { name = "buffer", priority = 10, keyword_length = 3, max_item_count = 8 },
          { name = "nvim_lua" },
          { name = "nvim_lsp_signature_help" },
        },
        mapping = cmp.mapping.preset.insert({
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
          }),

          -- Go to next placeholder in the snippet
          ["<C-l>"] = cmp.mapping(function(fallback)
            if luasnip.jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          -- Go to previous placeholder in the snippet
          ["<C-h>"] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),

          -- Super tab
          ["<Tab>"] = cmp.mapping(function(fallback)
            local col = vim.fn.col(".") - 1

            if cmp.visible() then
              cmp.select_next_item({ behavior = "select" })
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            elseif col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
              fallback()
            else
              cmp.complete()
            end
          end, { "i", "s" }),

          -- Super shift tab
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item({ behavior = "select" })
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        snippet = {
          expand = function(args)
            vim.snippet.expand(args.body)
          end,
        },
      })
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    cmd = { "LspInfo", "LspInstall", "LspStart" },
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
      { "williamboman/mason.nvim", config = true },
      { "williamboman/mason-lspconfig.nvim" },
    },
    config = function()
      -- require("ufo").setup()
      require("lspconfig.ui.windows").default_options.border = "single"
      vim.o.runtimepath = vim.o.runtimepath .. ",~/.dotfiles/.config/snippets"

      local lsp_capabilities = vim.tbl_deep_extend("force", require("cmp_nvim_lsp").default_capabilities(), {
        textDocument = {
          foldingRange = {
            dynamicRegistration = false,
            lineFoldingOnly = true,
          },
        },
      })

      local lspconfig_defaults = require("lspconfig").util.default_config
      lspconfig_defaults.capabilities = vim.tbl_deep_extend("force", lspconfig_defaults.capabilities, lsp_capabilities)

      local t = require("legendary.toolbox")
      local commands = {
        [":LspRestart"] = {
          description = "Restart any attached clients",
        },
        [":LspStart"] = {
          description = "Start the client manually",
        },
        [":LspInfo"] = {
          description = "Show attached clients",
        },
        [":LspUninstallAll"] = {
          description = "Uninstall all servers",
        },
        [":Mason"] = {
          description = "Open Mason",
        },
        [":MasonUninstallAll"] = {
          description = "Uninstall all Mason servers",
        },
      }
      local keymaps = {
        ["gf"] = {
          callback = function()
            return t.lazy_required_fn("telescope.builtin", "diagnostics", {
              layout_strategy = "center",
              bufnr = 0,
            })
          end,
          description = "Find diagnostics",
        },
        ["gq"] = {
          callback = function(bufnr)
            require("conform").format({ bufnr = bufnr })
          end,
          description = "Format buffer",
        },
        ["gr"] = {
          callback = function()
            t.lazy_required_fn("telescope.builtin", "lsp_references", {
              layout_strategy = "center",
            })
          end,
          description = "Find references",
        },
        ["gl"] = {
          callback = "<cmd>lua vim.diagnostic.open_float(0, { border = 'single', source = 'always' })<CR>",
          description = "Show line diagnostics",
        },
        ["K"] = {
          callback = "<cmd>lua vim.lsp.buf.hover()<CR>",
          description = "Show hover information",
        },
        ["<LocalLeader>p"] = {
          callback = function()
            t.lazy_required_fn("nvim-treesitter.textobjects.lsp_interop", "peek_definition_code", "@block.outer")
          end,
          description = "Peek definition",
        },
        ["ga"] = {
          callback = "<cmd>lua vim.lsp.buf.code_action()<CR>",
          description = "Get code actions",
        },
        ["gs"] = {
          callback = "<cmd>lua vim.lsp.buf.signature_help()<CR>",
          description = "Get signature help",
        },
        ["<LocalLeader>rn"] = {
          callback = "<cmd>lua vim.lsp.buf.rename()<CR>",
          description = "Rename symbol",
        },
        ["["] = {
          callback = "<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>",
          description = "Go to previous diagnostic",
        },
        ["]"] = {
          callback = "<cmd>lua vim.lsp.diagnostic.goto_next()<CR>",
          description = "Go to next diagnostic",
        },
      }

      -- Legendary.nvim
      local legendary = require("legendary")
      -- TODO: Add Legendary keymaps

      vim.iter(commands):each(function(command, value)
        legendary.command({ command, description = value.description })
      end)

      local function autocmds(client, bufnr)
        if client.supports_method("textDocument/documentHighlight") == false then
          return
        end
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
          buffer = bufnr,
          callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
          buffer = bufnr,
          callback = vim.lsp.buf.clear_references,
        })
      end

      -- LspAttach is where you enable features that only work
      -- if there is a language server active in the file
      vim.api.nvim_create_autocmd("LspAttach", {
        desc = "LSP actions",
        callback = function(event)
          local id = vim.tbl_get(event, "data", "client_id")
          local client = id and vim.lsp.get_client_by_id(id)
          if client == nil then
            return
          end

          local opts = { buffer = event.buf }

          autocmds(client, event.buf)
          vim.iter(keymaps):each(function(key, value)
            local mode = "n"
            if value.mode then
              mode = value.mode
            end

            local callback = value.callback
            if type(callback) == "function" then
              callback = function()
                callback(event.buf)
              end
            end

            vim.keymap.set(mode, key, value.callback, opts)
          end)
        end,
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

      require("mason-lspconfig").setup({
        ensure_installed = {
          "bashls",
          "cssls",
          "dockerls",
          -- "efm",
          "html",
          "intelephense",
          "jdtls",
          "jsonls",
          "lua_ls",
          "pyright",
          "ruby_lsp",
          -- "tailwindcss", -- Disabled due to high node CPU usage
          "vuels",
          "yamlls",
        },
        handlers = {
          -- this first function is the "default handler"
          -- it applies to every language server without a "custom handler"
          function(server_name)
            require("lspconfig")[server_name].setup({})
          end,
        },
      })
    end,
  },

  -- Code snippets
  "L3MON4D3/LuaSnip",
  "rafamadriz/friendly-snippets",

  -- Diagnostic signs
  {
    "ivanjermakov/troublesum.nvim",
    event = "LspAttach",
    opts = {
      enabled = function()
        local ft = vim.bo.filetype
        return ft ~= "lazy" and ft ~= "mason" and ft ~= "codecompanion"
      end,
      severity_format = vim
        .iter(ipairs(icons))
        :map(function(sev, icon)
          return icon
        end)
        :totable(),
    },
  },

  -- Formatting
  {
    "stevearc/conform.nvim",
    opts = {
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
        php = { "php-cs-fixer" },
        python = { "isort", "black" },
        ruby = { "rubocop" },
      },
    },
  },

  -- Others
  "onsails/lspkind.nvim",
}
