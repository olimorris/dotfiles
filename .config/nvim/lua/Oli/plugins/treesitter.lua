return {
  {
    "nvim-treesitter/nvim-treesitter", -- Smarter code understanding like syntax Highlight and navigation
    build = ":TSUpdate",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects", -- Syntax aware text-objects, select, move, swap, and peek support.
      "JoosepAlviste/nvim-ts-context-commentstring", -- Smart commenting in multi language files - Enabled in Treesitter file
      "windwp/nvim-ts-autotag", -- Autoclose and autorename HTML and Vue tags
      "RRethy/nvim-treesitter-endwise", -- Automatically add end keywords for Ruby, Lua, Python, and more
      {
        "windwp/nvim-autopairs", -- Autopair plugin
        config = {
          close_triple_quotes = true,
          check_ts = true,
          fast_wrap = {
            map = "<c-e>",
          },
        },
      },
      {
        "abecodes/tabout.nvim", -- Tab out from parenthesis, quotes, brackets...
        config = {
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

        -- nvim-ts-autotag plugin
        autotag = { enable = true },

        -- nvim-treesitter-endwise plugin
        endwise = { enable = true },

        -- nvim-ts-context-commentstring plugin
        context_commentstring = { enable = true },

        -- playground
        playground = {
          enable = true,
          disable = {},
          updatetime = 25, -- Debounced time for highlighting nodes in the playground from source code
          persist_queries = false, -- Whether the query persists across vim sessions
          keybindings = {
            toggle_query_editor = "o",
            toggle_hl_groups = "i",
            toggle_injected_languages = "t",
            toggle_anonymous_nodes = "a",
            toggle_language_display = "I",
            focus_language = "f",
            unfocus_language = "F",
            update = "R",
            goto_node = "<cr>",
            show_help = "?",
          },
        },
      })
    end,
  },
  {
    "nvim-treesitter/playground", -- View Treesitter definitions
    cmd = { "TSPlayground", "TSHighlightCapturesUnderCursor" },
    init = function()
      require("legendary").commands({
        {
          ":TSPlayground",
          description = "Treesitter Playground",
        },
      })
    end,
  },
}
