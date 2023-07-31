return {
  {
    "VonHeikemen/lsp-zero.nvim",
    branch = "v2.x",
    dependencies = {
      -- LSP Support
      "neovim/nvim-lspconfig",
      {
        "williamboman/mason.nvim",
        build = function() pcall(vim.cmd, "MasonUpdate") end,
      },
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
      "lukas-reineke/cmp-under-comparator",
      {
        "zbirenbaum/copilot-cmp",
        config = function() require("copilot_cmp").setup() end,
      },
      "onsails/lspkind.nvim",

      -- Snippets
      "L3MON4D3/LuaSnip",
      "rafamadriz/friendly-snippets",

      -- Misc
      {
        "KostkaBrukowa/definition-or-references.nvim", -- Definition and references in a single command
        config = function()
          local function handle_references_response(result)
            require("telescope.pickers")
              .new({}, {
                prompt_title = "LSP References",
                finder = require("telescope.finders").new_table({
                  results = vim.lsp.util.locations_to_items(result, "utf-16"),
                  entry_maker = require("telescope.make_entry").gen_from_quickfix(),
                }),
                layout_strategy = "center",
                previewer = require("telescope.config").values.qflist_previewer({}),
              })
              :find()
          end

          require("definition-or-references").setup({
            on_references_result = handle_references_response,
          })
        end,
      },
      {
        "VidocqH/lsp-lens.nvim", -- Display references and definitions
        config = true,
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
      vim.o.runtimepath = vim.o.runtimepath .. ",~/.dotfiles/.config/snippets"

      local lsp = require("lsp-zero").preset({
        set_lsp_keymaps = false,
        manage_nvim_cmp = {
          set_basic_mappings = true,
        },
      })

      lsp.set_sign_icons({
        error = " ",
        warn = " ",
        hint = " ",
        info = " ",
      })

      lsp.ensure_installed({
        "bashls",
        "cssls",
        "dockerls",
        "efm",
        "html",
        "intelephense",
        "jdtls",
        "jsonls",
        "lua_ls",
        "pyright",
        "solargraph",
        -- "tailwindcss", -- Disabled due to high node CPU usage
        "tsserver",
        "vuels",
        "yamlls",
      })

      -- we will use nvim-jdtls to setup the lsp
      lsp.skip_server_setup({ "jdtls" })

      lsp.set_server_config({
        capabilities = {
          textDocument = {
            foldingRange = {
              dynamicRegistration = false,
              lineFoldingOnly = true,
            },
          },
        },
      })

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
        if vim.g.lsp_commands then return {} end

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
            function() vim.cmd("edit " .. vim.lsp.get_log_path()) end,
            description = "Show logs",
          },
        })

        vim.g.lsp_commands = true
      end

      local function mappings(client, bufnr)
        if
          #vim.tbl_filter(
            function(keymap) return (keymap.desc or ""):lower() == "rename symbol" end,
            vim.api.nvim_buf_get_keymap(bufnr, "n")
          ) > 0
        then
          return
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
            -- { "gd", vim.lsp.buf.definition, description = "Go to definition", opts = { buffer = bufnr } },
            {
              "gd",
              require("definition-or-references").definition_or_references,
              description = "Go to definition/reference",
              opts = { silent = true },
            },
            { "gi", vim.lsp.buf.implementation, description = "Go to implementation", opts = { buffer = bufnr } },
            { "gt", vim.lsp.buf.type_definition, description = "Go to type definition", opts = { buffer = bufnr } },
            -- {
            --   "gr",
            --   t.lazy_required_fn("telescope.builtin", "lsp_references", {
            --     layout_strategy = "center",
            --   }),
            --   description = "Find references",
            --   opts = { buffer = bufnr },
            -- },
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

      lsp.on_attach(function(client, bufnr)
        autocmds(client, bufnr)
        commands(client, bufnr)
        mappings(client, bufnr)

        if client.name == "efm" then
          client.server_capabilities.documentFormattingProvider = true
          client.server_capabilities.documentFormattingRangeProvider = true
        end

        if client.server_capabilities.documentSymbolProvider then require("nvim-navic").attach(client, bufnr) end
      end)

      lsp.format_mapping("gq", {
        format_opts = {
          async = false,
          timeout_ms = 10000,
        },
        servers = {
          ["efm"] = {
            "css",
            "fish",
            "html",
            "lua",
            "java",
            "javascript",
            "json",
            "typescript",
            "markdown",
            "php",
            "python",
            "sh",
            "vue",
            "yaml",
          },
          ["solargraph"] = { "ruby" },
        },
      })

      lsp.setup()

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

      -- Setup better folding
      local ok, ufo = pcall(require, "ufo")
      if ok then require("ufo").setup() end

      --Setup completion
      local cmp = require("cmp")
      local cmp_action = require("lsp-zero").cmp_action()
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()

      vim.opt.completeopt = { "menu", "menuone", "noselect" }

      cmp.setup({
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
          -- <C-y> = Confirm snippet
          -- <C-p> / <Up> = Previous item
          -- <C-n> / <Down> = Next item

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
          { name = "luasnip", priority = 100, max_item_count = 8 },
          { name = "copilot", priority = 90, max_item_count = 8 },
          { name = "nvim_lsp", priority = 90, keyword_length = 3, max_item_count = 8 },
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
