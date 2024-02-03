return {
  "rebelot/heirline.nvim",
  lazy = true,
  config = function()
    require("heirline").setup({
      winbar = require("plugins.heirline.winbar"),
      statusline = require("plugins.heirline.statusline"),
      statuscolumn = require("plugins.heirline.statuscolumn"),
      opts = {
        disable_winbar_cb = function(args)
          local conditions = require("heirline.conditions")

          return conditions.buffer_matches({
            buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
            filetype = { "alpha", "codecompanion", "oil", "lspinfo", "toggleterm" },
          }, args.buf)
        end,
      },
    })
  end,
}
