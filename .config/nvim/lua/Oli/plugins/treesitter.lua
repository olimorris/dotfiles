local ok, treesitter = om.safe_require("nvim-treesitter.configs")
if not ok then
  return
end

treesitter.setup({
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

require("nvim-treesitter.configs").setup({ endwise = { enable = true } })
