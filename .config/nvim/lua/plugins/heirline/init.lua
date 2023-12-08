return {
  "rebelot/heirline.nvim",
  lazy = true,
  config = function()
    local filetypes = {
      "^git.*",
      "fugitive",
      "alpha",
      "^neo--tree$",
      "^neotest--summary$",
      "^neo--tree--popup$",
      "^NvimTree$",
      "^toggleterm$",
    }
    local buftypes = {
      "nofile",
      "prompt",
      "help",
      "quickfix",
    }
    local force_inactive_filetypes = {
      "^aerial$",
      "^alpha$",
      "^chatgpt$",
      "^DressingInput$",
      "^frecency$",
      "^lazy$",
      "^lazyterm$",
      "^netrw$",
      "^oil$",
      "^TelescopePrompt$",
      "^undotree$",
    }

    local heirline = require("heirline")
    local conditions = require("heirline.conditions")

    local winbar = require("plugins.heirline.winbar")
    local bufferline = require("plugins.heirline.bufferline")
    local statusline = require("plugins.heirline.statusline")

    local align = { provider = "%=" }
    local spacer = { provider = " " }

    statuscolumn = {
      condition = function()
        return not conditions.buffer_matches({
          buftype = buftypes,
          filetype = force_inactive_filetypes,
        })
      end,
      static = statuscolumn.static,
      init = statuscolumn.init,
      statuscolumn.signs,
      align,
      statuscolumn.line_numbers,
      spacer,
      statuscolumn.folds,
      statuscolumn.git_signs,
      -- statuscolumn.line,
    },
    heirline.setup({
      statusline = {
        static = {
          filetypes = filetypes,
          buftypes = buftypes,
          force_inactive_filetypes = force_inactive_filetypes,
        },
        condition = function(self)
          return not conditions.buffer_matches({
            filetype = self.force_inactive_filetypes,
          })
        end,
        statusline.VimMode,
        statusline.GitBranch,
        -- statusline.FileNameBlock,
        statusline.LspAttached,
        -- statusline.LspDiagnostics,
        align,
        statusline.Overseer,
        statusline.Dap,
        statusline.Lazy,
        statusline.FileType,
        -- statusline.FileEncoding,
        statusline.Session,
        statusline.MacroRecording,
        statusline.SearchResults,
        statusline.Ruler,
      },
      statuscolumn = require("plugins.heirline.statuscolumn"),
      winbar = {
        {
          condition = function()
            return conditions.buffer_matches({
              buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
              filetype = { "alpha", "oil", "lspinfo", "toggleterm" },
            })
          end,
          init = function()
            vim.opt_local.winbar = nil
          end,
        },
        winbar.filepath,
        winbar.filename,
        winbar.symbols,
        align,
        winbar.vim_logo,
      },
    })
  end,
}
