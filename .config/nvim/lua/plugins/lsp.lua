local icons = {
  [vim.diagnostic.severity.ERROR] = "",
  [vim.diagnostic.severity.WARN] = "",
  [vim.diagnostic.severity.INFO] = "",
  [vim.diagnostic.severity.HINT] = "",
}
return {
  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "saghen/blink.cmp", -- Better completion
        lazy = false,
        dependencies = {
          "rafamadriz/friendly-snippets",
          "L3MON4D3/LuaSnip",
        },
        build = "cargo build --release",
        opts = {
          -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
          keymap = {
            preset = "enter",
            ["<S-Tab>"] = { "select_prev", "fallback" },
            ["<Tab>"] = { "select_next", "fallback" },
            -- ["<CR>"] = { "accept", "fallback" },
            -- ["<C-e>"] = { "hide", "fallback" },
            -- ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
            -- ["<Tab>"] = { "snippet_forward", "fallback" },
            -- ["<S-Tab>"] = { "snippet_backward", "fallback" },
            -- ["<Up>"] = { "select_prev", "fallback" },
            -- ["<Down>"] = { "select_next", "fallback" },
            -- ["<C-b>"] = { "scroll_documentation_up", "fallback" },
            -- ["<C-f>"] = { "scroll_documentation_down", "fallback" },
          },

          highlight = {
            use_nvim_cmp_as_default = false,
          },
          -- experimental auto-brackets support
          accept = { auto_brackets = { enabled = true } },

          snippets = {
            expand = function(snippet)
              require("luasnip").lsp_expand(snippet)
            end,
            active = function(filter)
              if filter and filter.direction then
                return require("luasnip").jumpable(filter.direction)
              end
              return require("luasnip").in_snippet()
            end,
            jump = function(direction)
              require("luasnip").jump(direction)
            end,
          },

          -- experimental signature help support
          -- trigger = { signature_help = { enabled = true } }
          sources = {
            compat = {},
            completion = {
              enabled_providers = { "lsp", "path", "luasnip", "buffer", "codecompanion" },
            },
            providers = {
              codecompanion = {
                name = "CodeCompanion",
                module = "codecompanion.providers.completion.blink",
                enabled = true, -- Whether or not to enable the provider
              },
            },
          },
        },
      },
      {
        "williamboman/mason.nvim",
        build = function()
          pcall(vim.cmd, "MasonUpdate")
        end,
        opts = {
          ui = {
            border = "single",
            width = 0.9,
          },
        },
      },
      { "williamboman/mason-lspconfig.nvim" },
    },
    config = function(_, opts)
      require("lspconfig.ui.windows").default_options.border = "single"
      require("luasnip.loaders.from_vscode").lazy_load({ paths = { "~/.config/snippets" } })

      require("ufo").setup()
      local has_blink, blink = pcall(require, "blink.cmp")
      local capabilities =
        vim.tbl_deep_extend("force", has_blink and blink.get_lsp_capabilities() or {}, opts.capabilities or {}, {
          textDocument = {
            foldingRange = {
              dynamicRegistration = false,
              lineFoldingOnly = true,
            },
          },
        })

      local lspconfig_defaults = require("lspconfig").util.default_config
      lspconfig_defaults.capabilities = vim.tbl_deep_extend("force", lspconfig_defaults.capabilities, capabilities)

      -- Legendary.nvim
      local legendary = require("legendary")
      local t = require("legendary.toolbox")

      local function autocmds(client, bufnr)
        if not client.supports_method("textDocument/documentHighlight") then
          return
        end
        legendary.autocmds({
          {
            name = "LspOnAttachAutocmds",
            clear = false,
            {
              { "CursorHold", "CursorHoldI" },
              ":silent! lua vim.lsp.buf.document_highlight()",
              opts = { buffer = bufnr },
            },
            {
              "CursorMoved",
              ":silent! lua vim.lsp.buf.clear_references()",
              opts = { buffer = bufnr },
            },
          },
        })
      end
      local function commands(client, bufnr)
        -- Only need to set these once!
        if vim.g.lsp_commands then
          return {}
        end

        legendary.commands({
          {
            ":LspRestart",
            description = "Restart any attached clients",
          },
          {
            ":LspStart",
            description = "Start the client manually",
          },
          {
            ":LspInfo",
            description = "Show attached clients",
          },
          {
            "LspInstallAll",
            function()
              for _, name in pairs(om.lsp.servers) do
                vim.cmd("LspInstall " .. name)
              end
            end,
            description = "Install all servers",
          },
          {
            "LspUninstallAll",
            description = "Uninstall all servers",
          },
          {
            "LspLog",
            function()
              vim.cmd("edit " .. vim.lsp.get_log_path())
            end,
            description = "Show logs",
          },
        })

        vim.g.lsp_commands = true
      end
      local function mappings(client, bufnr)
        if
          #vim.tbl_filter(function(keymap)
            return (keymap.desc or ""):lower() == "rename symbol"
          end, vim.api.nvim_buf_get_keymap(bufnr, "n")) > 0
        then
          return {}
        end

        legendary.keymaps({
          itemgroup = "LSP",
          icon = "",
          description = "LSP related functionality",
          keymaps = {
            {
              "gf",
              t.lazy_required_fn("telescope.builtin", "diagnostics", {
                layout_strategy = "center",
                bufnr = 0,
              }),
              description = "Find diagnostics",
              opts = { noremap = true, buffer = bufnr },
            },
            {
              "gq",
              function()
                require("conform").format({ bufnr = bufnr })
              end,
              description = "Format",
              opts = { buffer = bufnr },
            },
            {
              "gr",
              t.lazy_required_fn("telescope.builtin", "lsp_references", {
                layout_strategy = "center",
              }),
              description = "Find references",
              opts = { buffer = bufnr },
            },
            {
              "gl",
              "<cmd>lua vim.diagnostic.open_float(0, { border = 'single', source = 'always' })<CR>",
              description = "Show line diagnostics",
              opts = { buffer = bufnr },
            },
            {
              "K",
              "<cmd>lua vim.lsp.buf.hover<CR>",
              description = "Show hover information",
              opts = { buffer = bufnr },
            },

            {
              "gd",
              "<cmd>lua vim.lsp.buf.definition()<CR>",
              description = "Go to definition",
              opts = { buffer = bufnr },
            },
            {
              "gi",
              "<cmd>lua vim.lsp.buf.implementation()<CR>",
              description = "Go to implementation",
              opts = { buffer = bufnr },
            },
            {
              "gt",
              "<cmd>lua vim.lsp.buf.type_definition()<CR>",
              description = "Go to type definition",
              opts = { buffer = bufnr },
            },
            {
              "<LocalLeader>p",
              t.lazy_required_fn("nvim-treesitter.textobjects.lsp_interop", "peek_definition_code", "@block.outer"),
              description = "Peek definition",
              opts = { buffer = bufnr },
            },
            {
              "ga",
              "<cmd>lua vim.lsp.buf.code_action()<CR>",
              description = "Show code actions",
              opts = { buffer = bufnr },
            },
            {
              "gs",
              "<cmd>lua vim.lsp.buf.signature_help()<CR>",
              description = "Show signature help",
              opts = { buffer = bufnr },
            },
            {
              "<LocalLeader>rn",
              "<cmd>lua vim.lsp.buf.rename()<CR>",
              description = "Rename symbol",
              opts = { buffer = bufnr },
            },

            {
              "[",
              "<cmd>lua vim.diagnostic.goto_prev()<CR>",
              description = "Go to previous diagnostic item",
              opts = { buffer = bufnr },
            },
            {
              "]",
              "<cmd>lua vim.diagnostic.goto_next()<CR>",
              description = "Go to next diagnostic item",
              opts = { buffer = bufnr },
            },
          },
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

          local bufnr = event.buf
          local opts = { buffer = bufnr }

          autocmds(client, bufnr)
          commands(client, bufnr)
          mappings(client, bufnr)
        end,
      })

      require("mason-lspconfig").setup({
        ensure_installed = {
          "bashls",
          "cssls",
          "dockerls",
          "html",
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
    end,
  },

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
