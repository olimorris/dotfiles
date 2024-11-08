local icons = {
  [vim.diagnostic.severity.ERROR] = "",
  [vim.diagnostic.severity.WARN] = "",
  [vim.diagnostic.severity.INFO] = "",
  [vim.diagnostic.severity.HINT] = "",
}

return {
  -- Completion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lua",
      "lukas-reineke/cmp-under-comparator",
    },
    config = function()
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()
      vim.opt.completeopt = { "menu", "menuone", "noselect" }

      local cmp = require("cmp")
      cmp.setup({
        formatting = {
          fields = { "abbr", "kind", "menu" },
          format = require("lspkind").cmp_format({
            mode = "symbol", -- show only symbol annotations
            maxwidth = 50, -- prevent the popup from showing more than provided characters
            ellipsis_char = "...", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead
          }),
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
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
        sources = {
          { name = "luasnip", priority = 100, max_item_count = 5 },
          { name = "nvim_lsp", priority = 90 },
          { name = "path", priority = 20 },
          { name = "buffer", priority = 10, keyword_length = 3, max_item_count = 8 },
          { name = "nvim_lua" },
          { name = "nvim_lsp_signature_help" },
        },
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" },
          {
            name = "cmdline",
            option = {
              ignore_cmds = { "Man", "!" },
            },
          },
        }),
        sorting = {
          comparators = {
            cmp.config.compare.offset,
            cmp.config.compare.exact,
            cmp.config.compare.score,
            cmp.config.compare.recently_used,
            require("cmp-under-comparator").under,
            cmp.config.compare.kind,
          },
        },
      })

      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" },
        },
      })
    end,
  },

  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "hrsh7th/cmp-nvim-lsp" },
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
    config = function()
      require("lspconfig.ui.windows").default_options.border = "single"
      vim.o.runtimepath = vim.o.runtimepath .. ",~/.dotfiles/.config/snippets"

      require("ufo").setup()
      local capabilities = vim.tbl_deep_extend("force", require("cmp_nvim_lsp").default_capabilities(), {
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
