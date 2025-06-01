local icons = {
  [vim.diagnostic.severity.ERROR] = "",
  [vim.diagnostic.severity.WARN] = "",
  [vim.diagnostic.severity.INFO] = "",
  [vim.diagnostic.severity.HINT] = "",
}

return {
  -- LSP
  {
    "mason-org/mason.nvim",
    opts = {
      ui = {
        border = "single",
        width = 0.9,
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    opts = {},
    config = function(_, opts)
      require("lspconfig.ui.windows").default_options.border = "single"
      -- require("luasnip.loaders.from_vscode").lazy_load({ paths = { "~/.config/snippets" } })

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
              function()
                require("snacks").picker.diagnostics_buffer()
              end,
              description = "Find diagnostics",
              opts = { noremap = true, buffer = bufnr },
            },
            {
              "gq",
              function()
                require("conform").format({ async = true, bufnr = bufnr, lsp_format = "fallback" })
              end,
              description = "Format",
              opts = { buffer = bufnr },
            },
            {
              "gr",
              function()
                require("snacks").picker.lsp_references()
              end,
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
              function()
                require("snacks").picker.lsp_definitions()
              end,
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
              "<cmd>lua vim.diagnostic.jump({count = -1, float = true})<CR>",
              description = "Go to previous diagnostic item",
              opts = { buffer = bufnr },
            },
            {
              "]",
              "<cmd>lua vim.diagnostic.jump({count = 1, float = true})<CR>",
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

          autocmds(client, bufnr)
          commands(client, bufnr)
          mappings(client, bufnr)
        end,
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
    end,
  },

  -- Completion
  {
    "saghen/blink.cmp",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "onsails/lspkind.nvim",
    },
    version = "*",
    opts = {
      cmdline = { sources = { "cmdline" } },
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

      appearance = {
        use_nvim_cmp_as_default = false,
        nerd_font_variant = "mono",
      },

      completion = {
        accept = { auto_brackets = { enabled = true } },

        documentation = {
          auto_show = true,
          auto_show_delay_ms = 250,
          treesitter_highlighting = true,
          window = { border = "rounded" },
        },

        list = {
          selection = {
            preselect = false,
            auto_insert = function(ctx)
              return ctx.mode == "cmdline" and "auto_insert" or "preselect"
            end,
          },
        },

        menu = {
          border = "rounded",

          cmdline_position = function()
            if vim.g.ui_cmdline_pos ~= nil then
              local pos = vim.g.ui_cmdline_pos -- (1, 0)-indexed
              return { pos[1] - 1, pos[2] }
            end
            local height = (vim.o.cmdheight == 0) and 1 or vim.o.cmdheight
            return { vim.o.lines - height, 0 }
          end,

          draw = {
            columns = {
              { "kind_icon", "label", gap = 1 },
              { "kind" },
            },
            components = {
              kind_icon = {
                text = function(item)
                  local kind = require("lspkind").symbol_map[item.kind] or ""
                  return kind .. " "
                end,
                highlight = "CmpItemKind",
              },
              label = {
                text = function(item)
                  return item.label
                end,
                highlight = "CmpItemAbbr",
              },
              kind = {
                text = function(item)
                  return item.kind
                end,
                highlight = "CmpItemKind",
              },
            },
          },
        },
      },

      -- My super-TAB configuration
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

      -- Experimental signature help support
      signature = {
        enabled = true,
        window = { border = "rounded" },
      },
    },
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
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
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
        python = { "isort", "black" },
        ruby = { "rubocop" },
      },
    },
  },
}
