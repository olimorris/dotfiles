return {
  {
    "nvim-treesitter/nvim-treesitter", -- Smarter code understanding like syntax Highlight and navigation
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects", -- Syntax aware text-objects, select, move, swap, and peek support.
      {
        "JoosepAlviste/nvim-ts-context-commentstring", -- Smart commenting in multi language files - Enabled in Treesitter file
        config = true,
      },
      {
        "windwp/nvim-ts-autotag", -- Autoclose and autorename HTML and Vue tags
        config = true,
      },
      {
        "PriceHiller/nvim-treesitter-endwise", -- Automatically add end keywords for Ruby, Lua, Python, and more
        branch = "fix/iter-matches",
      },
      {
        "windwp/nvim-autopairs", -- Autopair plugin
        opts = {
          close_triple_quotes = true,
          check_ts = true,
          enable_moveright = true,
          fast_wrap = {
            map = "<c-e>",
          },
        },
        config = function(_, opts)
          local autopairs = require("nvim-autopairs")

          autopairs.setup(opts)

          local Rule = require("nvim-autopairs.rule")
          local ts_conds = require("nvim-autopairs.ts-conds")

          autopairs.add_rules({
            Rule("{{", "  }", "vue"):set_end_pair_length(2):with_pair(ts_conds.is_ts_node("text")),
          })
        end,
      },
      {
        "abecodes/tabout.nvim", -- Tab out from parenthesis, quotes, brackets...
        opts = {
          tabkey = "<Tab>", -- key to trigger tabout, set to an empty string to disable
          backwards_tabkey = "<S-Tab>", -- key to trigger backwards tabout, set to an empty string to disable
          completion = true, -- We use tab for completion so set this to true
        },
      },
    },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = "all",
        ignore_install = { "phpdoc" }, -- list of parser which cause issues or crashes
        highlight = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<M-w>",
            scope_incremental = "<CR>",
            node_incremental = "<Tab>", -- increment to the upper named parent
            node_decremental = "<S-Tab>", -- decrement to the previous node
          },
        },
        indent = { enable = true },

        -- nvim-treesitter-endwise plugin
        endwise = { enable = true },

        textobjects = {
          select = {
            enable = true,
            lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim

            keymaps = {
              -- Use v[keymap], c[keymap], d[keymap] to perform any operation
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
            },
          },
        },
      })
    end,
  },
}
