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
    NORMAL = colors.purple,
    OP = colors.purple,
    INSERT = colors.green,
    VISUAL = colors.orange,
    LINES = colors.orange,
    BLOCK = colors.orange,
    REPLACE = colors.green,
    ["V-REPLACE"] = colors.green,
    ENTER = colors.cyan,
    MORE = colors.cyan,
    SELECT = colors.orange,
    COMMAND = colors.purple,
    SHELL = colors.purple,
    TERM = colors.purple,
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

  local function block(bg, fg)
    if not bg then
      bg = colors.statusline_bg
    end
    if not fg then
      fg = colors.statusline_text
    end
    return {
      body = {
        fg = fg,
        bg = bg,
      },
      sep_left = {
        fg = colors.bg,
        bg = bg,
      },
      sep_right = {
        fg = bg,
        bg = colors.bg,
      },
    }
  end

  local function inverse_block()
    return {
      body = {
        fg = colors.bg,
        bg = vim.o.background == "light" and colors.black or colors.gray,
      },
      sep_left = {
        fg = colors.bg,
        bg = vim.o.background == "light" and colors.black or colors.gray,
      },
      sep_right = {
        fg = vim.o.background == "light" and colors.black or colors.gray,
        bg = colors.bg,
      },
    }
  end

  M.components.inactive = { { { provider = "", hl = InactiveStatusHL } } }
  ---------------------------------------------------------------------------- }}}
  -------------------------------LEFT COMPONENTS------------------------------ {{{
  M.components.active[1] = {
    {
      provider = function()
        return require("feline.providers.vi_mode").get_vim_mode() .. " "
      end,
      icon = "",
      hl = function()
        return {
          fg = colors.bg,
          bg = vi_mode_utils.get_mode_color(),
        }
      end,
      left_sep = {
        str = "vertical_bar_thin",
        hl = function()
          return {
            fg = vi_mode_utils.get_mode_color(),
            bg = vi_mode_utils.get_mode_color(),
          }
        end,
      },
      right_sep = {
        str = "slant_right",
        hl = function()
          return {
            fg = vi_mode_utils.get_mode_color(),
            bg = colors.bg,
          }
        end,
      },
    },
    {
      provider = function()
        return "  " .. require("feline.providers.git").git_branch() .. " "
      end,
      truncate_hide = true,
      enabled = function()
        return git.git_info_exists() and there_is_width()
      end,
      hl = function()
        return block().body
      end,
      left_sep = {
        str = "slant_right",
        hl = function()
          return block().sep_left
        end,
      },
      right_sep = {
        str = "slant_right",
        hl = function()
          return block().sep_right
        end,
      },
    },
    { -- Spacer for if there is no width
      provider = " ",
      enabled = function()
        return not there_is_width()
      end,
      hl = function()
        return {
          bg = bg_to_mode_color and vi_mode_utils.get_mode_color() or "NONE",
        }
      end,
    },
    {
      provider = function()
        return " "
          .. require("feline.providers.file").file_info({
            icon = "",
          }, {
            type = "short",
          })
          .. " "
      end,
      hl = function()
        return block().body
      end,
      left_sep = {
        str = "slant_right",
        hl = function()
          return block().sep_left
        end,
      },
      right_sep = {
        str = "slant_right",
        hl = function()
          return block().sep_right
        end,
      },
    },
    {
      provider = "diagnostic_errors",
      icon = " ",
      enabled = function()
        return there_is_width()
      end,
      hl = function()
        return block(colors.red, colors.bg).body
      end,
      left_sep = {
        str = "slant_right",
        hl = function()
          return block(colors.red).sep_left
        end,
      },
      right_sep = {
        str = "slant_right",
        hl = function()
          return block(colors.red).sep_right
        end,
      },
    },
    {
      provider = "diagnostic_warnings",
      icon = " ",
      enabled = function()
        return there_is_width()
      end,
      hl = function()
        return block(colors.yellow, colors.bg).body
      end,
      left_sep = {
        str = "slant_right",
        hl = function()
          return block(colors.yellow).sep_left
        end,
      },
      right_sep = {
        str = "slant_right",
        hl = function()
          return block(colors.yellow).sep_right
        end,
      },
    },
    {
      provider = "diagnostic_hints",
      icon = " ",
      enabled = function()
        return there_is_width()
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
        str = " ",
        hl = function()
          return default_hl()
        end,
      },
    },
    {
      provider = "diagnostic_info",
      icon = " ",
      enabled = function()
        return there_is_width()
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
        str = " ",
        hl = function()
          return default_hl()
        end,
      },
    },
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
        str = "",
        hl = function()
          return default_hl()
        end,
      },
    },
    -- {
    -- {
    --     provider = "line_percentage",
    --     hl = function()
    --         return inverse_block().body
    --     end,
    --     left_sep = {
    --         str = "slant_left",
    --         hl = function()
    --             return inverse_block().sep_right
    --         end
    --     },
    --     right_sep = {
    --         str = "slant_left",
    --         hl = function()
    --             return inverse_block().sep_left
    --         end
    --     }
    -- },
    {
      provider = function()
        local filename = vim.api.nvim_buf_get_name(0)
        local extension = vim.fn.fnamemodify(filename, ":e")
        local filetype = vim.bo.filetype

        local icon = om.get_icon(filename, extension, {})
        return " " .. icon.str .. " " .. filetype .. " "
      end,
      hl = function()
        return block().body
      end,
      left_sep = {
        str = "slant_left",
        hl = function()
          return block().sep_right
        end,
      },
      right_sep = {
        str = "slant_left",
        hl = function()
          return block().sep_left
        end,
      },
    },
    {
      provider = function()
        if vim.g.persisting then
          return "   "
        elseif vim.g.persisting == false then
          return "   "
        end
      end,
      enabled = function()
        return using_session()
      end,
      hl = function()
        return block().body
      end,
      left_sep = {
        str = "slant_left",
        hl = function()
          return block().sep_right
        end,
      },
      right_sep = {
        str = "slant_left",
        hl = function()
          return block().sep_left
        end,
      },
    },
    {
      provider = function()
        return " " .. require("feline.providers.cursor").line_percentage()
      end,
      hl = function()
        return inverse_block().body
      end,
      left_sep = {
        str = "slant_left",
        hl = function()
          return inverse_block().sep_right
        end,
      },
      right_sep = {
        str = " ",
        hl = function()
          return inverse_block().body
        end,
      },
    },
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
