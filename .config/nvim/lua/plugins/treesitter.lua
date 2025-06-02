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
      "rrethy/nvim-treesitter-endwise", -- Automatically add end keywords for Ruby, Lua, Python, and more
      {
        "windwp/nvim-autopairs", -- Autopair plugin
        event = "InsertEnter",
        opts = {
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

-- TODO: for when Tree-sitter makes the main branch the default

-- return {
--   {
--     "nvim-treesitter/nvim-treesitter", -- Smarter code understanding like syntax Highlight and navigation
--     lazy = false,
--     branch = "main",
--     build = ":TSUpdate",
--     cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
--     event = { "BufReadPost", "BufNewFile", "BufWritePre" },
--     config = function()
--       require("nvim-treesitter").install({
--         "c",
--         "cpp",
--         "cmake",
--         "diff",
--         "gitcommit",
--         "gitignore",
--         "go",
--         "html",
--         "json",
--         "lua",
--         "markdown",
--         "markdown_inline",
--         "php",
--         "python",
--         "ruby",
--         "rust",
--         "toml",
--         "vim",
--         "vimdoc",
--         "vue",
--         "yaml",
--       })
--     end,
--   },
--   {
--     "nvim-treesitter/nvim-treesitter-textobjects", -- Syntax aware text-objects, select, move, swap, and peek support.
--     branch = "main",
--     keys = {
--       {
--         "af",
--         function()
--           require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
--         end,
--         desc = "Select outer function",
--         mode = { "x", "o" },
--       },
--       {
--         "if",
--         function()
--           require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
--         end,
--         desc = "Select inner function",
--         mode = { "x", "o" },
--       },
--       {
--         "ac",
--         function()
--           require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
--         end,
--         desc = "Select outer class",
--         mode = { "x", "o" },
--       },
--       {
--         "ic",
--         function()
--           require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
--         end,
--         desc = "Select inner class",
--         mode = { "x", "o" },
--       },
--       {
--         "as",
--         function()
--           require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
--         end,
--         desc = "Select local scope",
--         mode = { "x", "o" },
--       },
--     },
--     opts = {},
--   },
--   "JoosepAlviste/nvim-ts-context-commentstring", -- Smart commenting in multi language files - Enabled in Treesitter file
--   "windwp/nvim-ts-autotag", -- Autoclose and autorename HTML and Vue tags
--   --"rrethy/nvim-treesitter-endwise", -- Automatically add end keywords for Ruby, Lua, Python, and more
--   {
--     "windwp/nvim-autopairs", -- Autopair plugin
--     event = "InsertEnter",
--     opts = {
--       check_ts = true,
--       enable_moveright = true,
--       fast_wrap = {
--         map = "<c-e>",
--       },
--     },
--     config = function(_, opts)
--       local autopairs = require("nvim-autopairs")
--
--       autopairs.setup(opts)
--
--       local Rule = require("nvim-autopairs.rule")
--       local ts_conds = require("nvim-autopairs.ts-conds")
--
--       autopairs.add_rules({
--         Rule("{{", "  }", "vue"):set_end_pair_length(2):with_pair(ts_conds.is_ts_node("text")),
--       })
--     end,
--   },
-- }
--
