local M = {
  "rebelot/heirline.nvim",
  priority = 500,
  dependencies = {
    {
      "famiu/bufdelete.nvim", -- Easily close buffers whilst preserving your window layouts
      cmd = "Bdelete",
    },
    "nvim-tree/nvim-web-devicons",
    {
      "SmiteshP/nvim-navic", -- Winbar component showing current code context
      opts = {
        highlight = true,
        separator = "  ",
      },
    },
  },
  init = function()
    require("legendary").keymaps({
      { "<C-c>", "<cmd>Bdelete<CR>", hide = true, description = "Close Buffer" }, -- bufdelete.nvim
      { "<Tab>", "<cmd>bnext<CR>", hide = true, description = "Next buffer", opts = { noremap = false } }, -- Heirline.nvim
      { "<S-Tab>", "<cmd>bprev<CR>", hide = true, description = "Previous buffer", opts = { noremap = false } }, -- Heirline.nvim
    })
  end,
}

-- Filetypes where certain elements of the statusline will not be shown
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

-- Buftypes which should cause elements to be hidden
local buftypes = {
  "nofile",
  "prompt",
  "help",
  "quickfix",
}

-- Filetypes which force the statusline to be inactive
local force_inactive_filetypes = {
  "^aerial$",
  "^alpha$",
  "^chatgpt$",
  "^DressingInput$",
  "^frecency$",
  "^lazy$",
  "^netrw$",
  "^oil$",
  "^TelescopePrompt$",
  "^undotree$",
}

---Load the bufferline, tabline and statusline. Extracting this to a seperate
function M.config()
  local heirline = require("heirline")
  local conditions = require("heirline.conditions")

  local winbar = require(config_namespace .. ".plugins.heirline.winbar")
  local bufferline = require(config_namespace .. ".plugins.heirline.bufferline")
  local statusline = require(config_namespace .. ".plugins.heirline.statusline")
  local statuscolumn = require(config_namespace .. ".plugins.heirline.statuscolumn")

  local align = { provider = "%=" }
  local spacer = { provider = " " }

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
      statusline.FileNameBlock,
      statusline.LspAttached,
      statusline.LspDiagnostics,
      align,
      statusline.Overseer,
      statusline.Dap,
      statusline.Lazy,
      statusline.FileType,
      statusline.FileEncoding,
      statusline.Session,
      statusline.MacroRecording,
      statusline.SearchResults,
      statusline.Ruler,
    },
    statuscolumn = {
      condition = function()
        -- TODO: Update this when 0.9 is released
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
    },
    winbar = {
      {
        condition = function()
          return conditions.buffer_matches({
            buftype = { "nofile", "prompt", "help", "quickfix", "terminal" },
            filetype = { "alpha", "oil", "toggleterm" },
          })
        end,
        init = function() vim.opt_local.winbar = nil end,
      },
      winbar.filepath,
      winbar.filename,
      winbar.navic,
      align,
      winbar.vim_logo,
    },
  })
end

return M
