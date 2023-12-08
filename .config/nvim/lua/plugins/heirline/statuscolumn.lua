local conditions = require("heirline.conditions")

return {
  {
    static = {
      git_ns = vim.api.nvim_create_namespace("gitsigns_extmark_signs_"),
    },
    -- Signs
    {
      init = function(self)
        local signs = {}

        local extmarks = vim.api.nvim_buf_get_extmarks(
          0,
          -1,
          { vim.v.lnum - 1, 0 },
          { vim.v.lnum - 1, -1 },
          { details = true, type = "sign" }
        )

        for _, extmark in pairs(extmarks) do
          if extmark[4].ns_id ~= self.git_ns then
            signs[#signs + 1] = {
              name = extmark[4].sign_hl_group or "",
              text = extmark[4].sign_text,
              sign_hl_group = extmark[4].sign_hl_group,
              priority = extmark[4].priority,
            }
          end
        end

        -- Sort by priority
        table.sort(signs, function(a, b)
          return (a.priority or 0) < (b.priority or 0)
        end)

        self.sign = signs[1]
      end,
      provider = function(self)
        return self.sign and self.sign.text or ""
      end,
      hl = function(self)
        return self.sign and self.sign.sign_hl_group
      end,
    },
    -- Line Numbers
    {
      provider = "%=%4{v:virtnum ? '' : &nu ? (&rnu && v:relnum ? v:relnum : v:lnum) . ' ' : ''}",
    },
    -- Git Signs
    {
      {
        condition = function()
          return conditions.is_git_repo() and vim.v.virtnum == 0
        end,
        init = function(self)
          if self.git_ns then
            local extmark = vim.api.nvim_buf_get_extmarks(
              0,
              self.git_ns,
              { vim.v.lnum - 1, 0 },
              { vim.v.lnum, 0 },
              { limit = 1, details = true }
            )[1]

            self.sign = extmark and extmark[4]["sign_hl_group"]
          end
        end,
        {
          provider = "│",
          hl = function(self)
            return self.sign or { fg = "bg" }
          end,
          on_click = {
            name = "heirline_statuscolumn_gitsigns",
            callback = function(_self)
              local mouse = vim.fn.getmousepos()
              local cursor_pos = { mouse.line, 0 }
              vim.api.nvim_win_set_cursor(mouse.winid, cursor_pos)
              vim.defer_fn(function()
                require("gitsigns").blame_line({ full = true })
              end, 100)
            end,
          },
        },
      },
    },
  },
}
