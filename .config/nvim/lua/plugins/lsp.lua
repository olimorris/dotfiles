local lsp_buffers = {}

local icons = {
  error = "",
  warn = "",
  info = "",
  hint = "",
}

return {
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v4.x",
    dependencies = {
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
      "williamboman/mason-lspconfig.nvim",

      -- LSP Support
      "neovim/nvim-lspconfig",

      -- Autocompletion
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-nvim-lua",
      "lukas-reineke/cmp-under-comparator",
      "zbirenbaum/copilot-cmp",
      "onsails/lspkind.nvim",

      -- Snippets
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",

      -- Misc
      {
        "ivanjermakov/troublesum.nvim", -- LSP diagnostics in virtual text at the top of the screen
        event = "LspAttach",
        opts = {
          enabled = function()
            local ft = vim.bo.filetype
            return ft ~= "lazy" and ft ~= "mason" and ft ~= "codecompanion"
          end,
          severity_format = { icons.error, icons.warn, icons.info, icons.hint },
        },
      },
      {
        "stevearc/conform.nvim", -- Formatting plugin
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
    },
    init = function()
      require("legendary").commands({
        {
          ":Mason",
          description = "Open Mason",
        },
        {
          ":MasonUninstallAll",
          description = "Uninstall all Mason packages",
        },
      })
      require("legendary").keymaps({
        itemgroup = "Completion",
        icon = "",
        description = "Completion related functionality...",
        keymaps = {
          {
            "<Enter>",
            description = "Confirms selection",
          },
          {
            "<Up>",
            description = "Go to previous item on the list",
          },
          {
            "<Down>",
            description = "Go to next item on the list",
          },
          {
            "<Ctrl-e>",
            description = "Toggle completion menu",
          },
          {
            "<Ctrl-h>",
            description = "Go to previous placeholder in snippet",
          },
          {
            "<Ctrl-l>",
            description = "Go to next placeholder in snippet",
          },
          {
            "<Tab>",
            description = "Enable completion when inside a word OR go to next item",
          },
          {
            "<S-Tab>",
            description = "Go to previous item",
          },
        },
      })
    end,
    config = function()
      require("lspconfig.ui.windows").default_options.border = "single"
      vim.o.runtimepath = vim.o.runtimepath .. ",~/.dotfiles/.config/snippets"

      local lsp_zero = require("lsp-zero")

      local function autocmds(client, bufnr)
        require("legendary").autocmds({
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

        require("legendary").commands({
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

        local t = require("legendary.toolbox")

        require("legendary").keymaps({
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
              opts = { noremap = true },
            },
            { "gd", vim.lsp.buf.definition, description = "Go to definition", opts = { buffer = bufnr } },
            { "gi", vim.lsp.buf.implementation, description = "Go to implementation", opts = { buffer = bufnr } },
            { "gt", vim.lsp.buf.type_definition, description = "Go to type definition", opts = { buffer = bufnr } },
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
              description = "Line diagnostics",
              opts = { buffer = bufnr },
            },
            {
              "K",
              vim.lsp.buf.hover,
              description = "Show hover information",
              opts = {
                buffer = bufnr,
              },
            },
            {
              "<LocalLeader>p",
              t.lazy_required_fn("nvim-treesitter.textobjects.lsp_interop", "peek_definition_code", "@block.outer"),
              description = "Peek definition",
              opts = { buffer = bufnr },
            },
            {
              "ga",
              vim.lsp.buf.code_action,
              description = "Show code actions",
              opts = {
                buffer = bufnr,
              },
            },
            {
              "gs",
              vim.lsp.buf.signature_help,
              description = "Show signature help",
              opts = {
                buffer = bufnr,
              },
            },
            {
              "<LocalLeader>rn",
              vim.lsp.buf.rename,
              description = "Rename symbol",
              opts = {
                buffer = bufnr,
              },
            },

            {
              "[",
              vim.diagnostic.goto_prev,
              description = "Go to previous diagnostic item",
              opts = { buffer = bufnr },
            },
            { "]", vim.diagnostic.goto_next, description = "Go to next diagnostic item", opts = { buffer = bufnr } },
          },
        })
      end

      lsp_zero.on_attach(function(client, bufnr)
        if vim.tbl_contains(lsp_buffers, bufnr) then
          return
        end

        autocmds(client, bufnr)
        commands(client, bufnr)
        mappings(client, bufnr)

        table.insert(lsp_buffers, bufnr)
      end)

      require("mason").setup({})
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
          lsp_zero.default_setup,
          jdtls = lsp_zero.noop, -- Use nvim-jdtls to setup the lsp
        },
      })

      -- For nvim-ufo folding
      require("ufo").setup()
      require("lspconfig").yamlls.setup({
        capabilities = {
          textDocument = {
            foldingRange = {
              dynamicRegistration = false,
              lineFoldingOnly = true,
            },
          },
        },
      })
      lsp_zero.set_server_config({
        capabilities = {
          textDocument = {
            foldingRange = {
              dynamicRegistration = false,
              lineFoldingOnly = true,
            },
          },
        },
      })

      vim.diagnostic.config({
        severity_sort = true,
        signs = true,
        underline = false,
        update_in_insert = true,
        virtual_text = false,
        -- virtual_text = {
        --   prefix = "",
        --   spacing = 0,
        -- },
      })

      lsp_zero.set_sign_icons(icons)

      -- Completion
      local cmp = require("cmp")
      local cmp_action = require("lsp-zero").cmp_action()
      local luasnip = require("luasnip")
      -- require("copilot_cmp").setup()

      require("luasnip.loaders.from_vscode").lazy_load()

      vim.opt.completeopt = { "menu", "menuone", "noselect" }

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
        mapping = {
          -- <C-p> / <Up> = Previous item
          -- <C-n> / <Down> = Next item
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
          }),
          ["<Tab>"] = cmp_action.luasnip_supertab(),
          ["<S-Tab>"] = cmp_action.luasnip_shift_supertab(),

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
          { name = "luasnip", priority = 100, max_item_count = 5 },
          -- { name = "copilot", priority = 90, max_item_count = 5 },
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
}
