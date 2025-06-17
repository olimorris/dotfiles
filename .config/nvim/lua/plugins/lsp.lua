local icons = {
  [vim.diagnostic.severity.ERROR] = "",
  [vim.diagnostic.severity.WARN] = "",
  [vim.diagnostic.severity.INFO] = "",
  [vim.diagnostic.severity.HINT] = "",
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

      -- LspAttach is where you enable features that only work
      -- if there is a language server active in the file
      om.create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp-attach", { clear = true }),
        desc = "LSP actions",
        callback = function(event)
          local bufnr = event.buf

          ---Shortcut function to map keys
          ---@param keys string|table
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

          -- This function resolves a difference between neovim nightly (version 0.11) and stable (version 0.10)
          ---@param client vim.lsp.Client
          ---@param method vim.lsp.protocol.Method
          ---@param bufnr? integer some lsp support methods only in specific files
          ---@return boolean
          local function client_supports_method(client, method, bufnr)
            return client:supports_method(method, bufnr)
          end

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if
            client
            and client_supports_method(client, vim.lsp.protocol.Methods.textDocument_documentHighlight, event.buf)
          then
            local highlight_augroup = vim.api.nvim_create_augroup("lsp-highlight", { clear = false })

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
              group = vim.api.nvim_create_augroup("lsp-detach", { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds({ group = "lsp-highlight", buffer = event2.buf })
              end,
            })
          end
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
