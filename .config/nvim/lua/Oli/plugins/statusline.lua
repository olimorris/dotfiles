local ok, feline = om.safe_require("feline")
if not ok then
  return
end
---------------------------------PROPERTIES--------------------------------- {{{
local M = {}
local lsp = require("feline.providers.lsp")
local git = require("feline.providers.git")
local vi_mode_utils = require("feline.providers.vi_mode")
local bg_to_mode_color = false -- Set the whole statusbar to be the color of the vim

M.components = { active = {}, inactive = {} }
M.force_inactive = {
  filetypes = { "^aerial$", "^NvimTree$", "^neo$", "^neo-tree-popup$", "^toggleterm$", "^undotree$" },
}
M.disable = {
  filetypes = {
    "^alpha$",
    "^dap-repl$",
    "^dapui_scopes$",
    "^dapui_stacks$",
    "^dapui_breakpoints$",
    "^dapui_watches$",
    "^DressingInput$",
    "^DressingSelect$",
    "^floaterm$",
    "^minimap$",
    "^qfs$",
    "^tsplayground$",
  },
}
---------------------------------------------------------------------------- }}}
-----------------------------------HELPERS---------------------------------- {{{
-- Determine if we're using a session file
local function using_session()
  return (vim.g.persisting ~= nil)
end

-- Determine if there is enough space in the window to display components
local function there_is_width()
  return vim.api.nvim_win_get_width(0) > 80
end

local function async_run()
  if vim.g.async_status == "running" then
    local spinners = {
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
      "",
    }
    local ms = vim.loop.hrtime() / 1000000
    local frame = math.floor(ms / 60) % #spinners
    return spinners[frame + 1] .. " "
  end
  if vim.g.async_status == "fail" then
    return " "
  end
  if vim.g.async_status == "success" then
    return " "
  end
  return nil
end
---------------------------------------------------------------------------- }}}
---------------------------------COMPONENTS--------------------------------- {{{
------------------------------------SETUP----------------------------------- {{{
function M.setup()
  local colors = require("onedarkpro").get_colors(vim.g.onedarkpro_style)
  M.vi_mode_colors = {
    NORMAL = colors.green,
    OP = colors.green,
    INSERT = colors.red,
    VISUAL = colors.blue,
    LINES = colors.blue,
    BLOCK = colors.blue,
    REPLACE = colors.purple,
    ["V-REPLACE"] = colors.purple,
    ENTER = colors.cyan,
    MORE = colors.cyan,
    SELECT = colors.orange,
    COMMAND = colors.green,
    SHELL = colors.green,
    TERM = colors.green,
    NONE = colors.yellow,
  }

  local InactiveStatusHL = {
    fg = colors.statusline_div,
    bg = "NONE",
    style = "underline",
  }

  local function default_hl()
    return {
      fg = bg_to_mode_color and colors.bg or colors.gray,
      bg = bg_to_mode_color and vi_mode_utils.get_mode_color() or "NONE",
    }
  end

  M.components.inactive = { { { provider = "", hl = InactiveStatusHL } } }
  ---------------------------------------------------------------------------- }}}
  -------------------------------LEFT COMPONENTS------------------------------ {{{
  M.components.active[1] = {
    {
      provider = " ",
      enabled = not bg_to_mode_color,
      hl = function()
        return { fg = "NONE", bg = vi_mode_utils.get_mode_color() }
      end,
      right_sep = {
        str = "",
        enabled = not bg_to_mode_color,
        hl = function()
          return default_hl()
        end,
      },
    },
    {
      provider = function()
        return async_run()
      end,
      enabled = function()
        return async_run() ~= nil
      end,
      hl = function()
        return default_hl()
      end,
      left_sep = {
        str = " ",
        hl = function()
          return default_hl()
        end,
      },
      right_sep = {
        str = "|",
        hl = function()
          return default_hl()
        end,
      },
    },
    {
      provider = function()
        if vim.g.persisting then
          return "  "
        elseif vim.g.persisting == false then
          return "  "
        end
      end,
      enabled = function()
        return using_session()
      end,
      hl = function()
        return default_hl()
      end,
    },
    { -- Spacer for if there is no width
      provider = " ",
      enabled = function(winid)
        return not there_is_width(winid)
      end,
      hl = function()
        return {
          bg = bg_to_mode_color and vi_mode_utils.get_mode_color() or "NONE",
        }
      end,
    },
    {
      provider = {
        name = "file_info",
        opts = { type = "relative", colored_icon = false },
      },
      icon = "",
      left_sep = {
        str = " ",
        hl = function()
          return default_hl()
        end,
      },
      hl = function()
        return default_hl()
      end,
    },
    -- {
    --     provider = "lsp_client_names",
    --     truncate_hide = true,
    --     enabled = function(winid)
    --         return lsp.is_lsp_attached() and there_is_width(winid)
    --     end,
    --     icon = "",
    --     hl = function()
    --         return default_hl()
    --     end,
    --     left_sep = {
    --         str = " [LSP: ",
    --         hl = function()
    --             return default_hl()
    --         end
    --     },
    --     right_sep = {
    --         str = "]",
    --         hl = function()
    --             return default_hl()
    --         end
    --     }
    -- },
    -- Fill in the section between the left and the right components
    {
      hl = function()
        return default_hl()
      end,
    },
  }
  ---------------------------------------------------------------------------- }}}
  ------------------------------RIGHT COMPONENTS------------------------------ {{{
  M.components.active[2] = {
    {
      provider = "diagnostic_errors",
      icon = "  ",
      enabled = function(winid)
        return there_is_width(winid)
      end,
      hl = function()
        return default_hl()
      end,
    },
    {
      provider = "diagnostic_warnings",
      icon = "  ",
      enabled = function(winid)
        return there_is_width(winid)
      end,
      hl = function()
        return default_hl()
      end,
    },
    {
      provider = "diagnostic_hints",
      icon = "  ",
      enabled = function(winid)
        return there_is_width(winid)
      end,
      hl = function()
        return default_hl()
      end,
    },
    {
      provider = "diagnostic_info",
      icon = "  ",
      enabled = function(winid)
        return there_is_width(winid)
      end,
      hl = function()
        return default_hl()
      end,
    },
    {
      provider = " |",
      enabled = function(winid)
        return lsp.diagnostics_exist() and there_is_width(winid)
      end,
      hl = function()
        return default_hl()
      end,
    },
    {
      provider = "git_branch",
      truncate_hide = true,
      enabled = function(winid)
        return git.git_info_exists(winid) and there_is_width(winid)
      end,
      hl = function()
        return default_hl()
      end,
      left_sep = {
        str = " ",
        hl = function()
          return default_hl()
        end,
      },
    },
    {
      provider = "git_diff_added",
      enabled = function(winid)
        return git.git_info_exists(winid) and there_is_width(winid)
      end,
      hl = function()
        return default_hl()
      end,
      icon = " +",
    },
    {
      provider = "git_diff_changed",
      enabled = function(winid)
        return git.git_info_exists(winid) and there_is_width(winid)
      end,
      hl = function()
        return default_hl()
      end,
      icon = " ~",
    },
    {
      provider = "git_diff_removed",
      enabled = function(winid)
        return git.git_info_exists(winid) and there_is_width(winid)
      end,
      hl = function()
        return default_hl()
      end,
      icon = " -",
    },
    -- {
    --     provider = " | ",
    --     enabled = function(winid)
    --         return git.git_info_exists(winid) and there_is_width(winid)
    --     end,
    --     hl = function()
    --         return default_hl()
    --     end
    -- },
    -- {
    --     provider = "line_percentage",
    --     hl = function()
    --         return default_hl()
    --     end,
    --     right_sep = {
    --         str = " ",
    --         hl = function()
    --             return default_hl()
    --         end
    --     }
    -- },
    -- {
    --     provider = "scroll_bar",
    --     hl = function()
    --         return default_hl()
    --     end
    -- }
  }
  ---------------------------------------------------------------------------- }}}
  -------------------------------FINALISE SETUP------------------------------- {{{
  feline.setup({
    colors = { fg = "NONE", bg = "NONE" },
    vi_mode_colors = M.vi_mode_colors,
    components = M.components,
    disable = M.disable,
    force_inactive = M.force_inactive,
  })
end
---------------------------------------------------------------------------- }}}
return M
