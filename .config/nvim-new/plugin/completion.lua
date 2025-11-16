require("blink.cmp").setup({
  fuzzy = { implementation = "prefer_rust_with_warning" },
  signature = { enabled = true },
  keymap = {
    preset = "default",
    ["<C-space>"] = {},
    ["<C-p>"] = {},
    ["<C-k>"] = {},
    ["<C-j>"] = {},
    ["<C-y>"] = { "show", "show_documentation", "hide_documentation" },
    ["<CR>"] = { "select_and_accept", "fallback" },
    ["<S-Tab>"] = { "select_prev", "fallback" },
    ["<Tab>"] = { "select_next", "fallback" },
    ["<C-b>"] = { "scroll_documentation_down", "fallback" },
    ["<C-f>"] = { "scroll_documentation_up", "fallback" },
    ["<C-l>"] = { "snippet_forward", "fallback" },
    ["<C-h>"] = { "snippet_backward", "fallback" },
    ["<C-e>"] = { "hide" },
  },

  appearance = {
    use_nvim_cmp_as_default = false,
    nerd_font_variant = "mono",
  },

  completion = {
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
    },
    list = {
      selection = {
        preselect = function(ctx)
          return not require("blink.cmp").snippet_active({ direction = 1 })
        end,
        auto_insert = false,
      },
    },
  },

  cmdline = { sources = { "cmdline" } },

  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
    providers = {
      snippets = {
        min_keyword_length = 1,
        opts = {
          search_paths = { "~/.config/snippets" },
        },
      },
    },
  },
})
