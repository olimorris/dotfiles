require("heirline").setup({
  winbar = require("plugins.statusline.winbar"),
  statusline = require("plugins.statusline.statusline"),
  statuscolumn = require("plugins.statusline.statuscolumn"),
  opts = {
    disable_winbar_cb = function(args)
      local conditions = require("heirline.conditions")

      return conditions.buffer_matches({
        buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
        filetype = { "alpha", "codecompanion", "oil", "lspinfo", "snacks_dashboard", "toggleterm" },
      }, args.buf)
    end,
  },
})
