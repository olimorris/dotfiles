local M = {
  "rebelot/heirline.nvim",
  priority = 500,
  dependencies = {
    {
      "famiu/bufdelete.nvim", -- Easily close buffers whilst preserving your window layouts
      cmd = "Bdelete",
    },
    "nvim-tree/nvim-web-devicons",
  },
  init = function()
    require("legendary").keymaps({
      { "<C-c>", "<cmd>Bdelete<CR>", hide = true, description = "Close Buffer" }, -- bufdelete.nvim
      { "<Tab>", "<cmd>bnext<CR>", hide = true, description = "Next buffer", opts = { noremap = false } }, -- Heirline.nvim
      { "<S-Tab>", "<cmd>bprev<CR>", hide = true, description = "Previous buffer", opts = { noremap = false } }, -- Heirline.nvim
      {
        "<Leader>b",
        function()
          local tabline = require("heirline").tabline
          local buflist = tabline._buflist[1]
          buflist._picker_labels = {}
          buflist._show_picker = true
          vim.cmd.redrawtabline()
          local char = vim.fn.getcharstr()
          local bufnr = buflist._picker_labels[char]
          if bufnr then vim.api.nvim_win_set_buf(0, bufnr) end
          buflist._show_picker = false
          vim.cmd.redrawtabline()
        end,
        hide = true,
        description = "Navigate to buffer",
        opts = { noremap = false },
      },
    })
  end,
}

-- Filetypes where certain elements of the statusline will not be shown
local filetypes = {
  "^neo--tree$",
  "^neotest--summary$",
  "^neo--tree--popup$",
  "^NvimTree$",
  "^toggleterm$",
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
  "^TelescopePrompt$",
  "^undotree$",
}

---Load the bufferline, tabline and statusline. Extracting this to a seperate
---function allows us to call it from autocmds and preserve colors
function M.load()
  local heirline = require("heirline")
  local conditions = require("heirline.conditions")

  local statusline = require(config_namespace .. ".plugins.heirline.statusline")
  local statuscolumn = require(config_namespace .. ".plugins.heirline.statuscolumn")
  local bufferline = require(config_namespace .. ".plugins.heirline.bufferline")

  local align = { provider = "%=" }
  local spacer = { provider = " " }

  heirline.load_colors(require("onedarkpro.helpers").get_colors())
  heirline.setup({
    statusline = {
      static = {
        filetypes = filetypes,
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
      statusline.LspDiagnostics,
      align,
      statusline.Overseer,
      statusline.Dap,
      statusline.Lazy,
      statusline.FileType,
      statusline.FileEncoding,
      statusline.Session,
      statusline.SearchResults,
      statusline.Ruler,
    },
    statuscolumn = {
      condition = function()
        return not conditions.buffer_matches({
          filetype = force_inactive_filetypes,
        })
      end,
      static = statuscolumn.static,
      init = statuscolumn.init,
      statuscolumn.diagnostics,
      statuscolumn.debug,
      align,
      statuscolumn.line_numbers,
      spacer,
      statuscolumn.folds,
      statuscolumn.git_signs,
    },
    tabline = bufferline,
  })

  vim.o.showtabline = 2
  vim.cmd([[au FileType * if index(['wipe', 'delete'], &bufhidden) >= 0 | set nobuflisted | endif]])
end

---Used by Lazy to load the statusline
function M.config() M.load() end

return M
