return {
  {
    "nvim-treesitter/nvim-treesitter", -- Smarter code understanding like syntax Highlight and navigation
    lazy = false,
    branch = "main",
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local filetype = args.match
          local lang = vim.treesitter.language.get_lang(filetype)
          if vim.treesitter.language.add(lang) then
            vim.treesitter.start()
          end
        end,
      })
    end,
    config = function()
      require("nvim-treesitter").install({
        "css",
        "diff",
        "gitcommit",
        "gitignore",
        "go",
        "fish",
        "html",
        "javascript",
        "json",
        "latex",
        "ledger",
        "lua",
        "markdown",
        "markdown_inline",
        "norg",
        "php",
        "python",
        "regex",
        "ruby",
        "rust",
        "scss",
        "svelte",
        "toml",
        "tsx",
        "typst",
        "vim",
        "vimdoc",
        "vue",
        "yaml",
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects", -- Syntax aware text-objects, select, move, swap, and peek support.
    branch = "main",
    keys = {
      {
        "af",
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@function.outer", "textobjects")
        end,
        desc = "Select outer function",
        mode = { "x", "o" },
      },
      {
        "if",
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@function.inner", "textobjects")
        end,
        desc = "Select inner function",
        mode = { "x", "o" },
      },
      {
        "ac",
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@class.outer", "textobjects")
        end,
        desc = "Select outer class",
        mode = { "x", "o" },
      },
      {
        "ic",
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@class.inner", "textobjects")
        end,
        desc = "Select inner class",
        mode = { "x", "o" },
      },
      {
        "as",
        function()
          require("nvim-treesitter-textobjects.select").select_textobject("@local.scope", "locals")
        end,
        desc = "Select local scope",
        mode = { "x", "o" },
      },
    },
    opts = {},
  },
  "JoosepAlviste/nvim-ts-context-commentstring", -- Smart commenting in multi language files - Enabled in Treesitter file
  "windwp/nvim-ts-autotag", -- Autoclose and autorename HTML and Vue tags
  --"rrethy/nvim-treesitter-endwise", -- Automatically add end keywords for Ruby, Lua, Python, and more
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
}
