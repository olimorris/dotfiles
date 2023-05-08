local ok, legendary = pcall(require, "legendary")
if not ok then return end

return {
  {
    name = "ConcealAttributes",
    {
      { "BufEnter", "BufWritePost", "TextChanged", "InsertLeave" },
      function()
        vim.opt.conceallevel = 2 -- Concealed text is completely hidden
        local bufnr = vim.api.nvim_get_current_buf()
        om.ConcealHTML(bufnr)
      end,
      opts = {
        pattern = { "*.html" },
      },
    },
  },
  {
    name = "Heirline",
    {
      "ColorScheme",
      function()
        local utils = require("heirline.utils")
        utils.on_colorscheme(require("onedarkpro.helpers").get_colors())
      end,
      opts = {
        pattern = { "*" },
      },
    },
    {
      "User",
      function(args)
        local buf = args.buf
        local buftype = vim.tbl_contains({ "prompt", "nofile", "help", "quickfix" }, vim.bo[buf].buftype)
        local filetype = vim.tbl_contains({ "", "alpha", "gitcommit", "fugitive" }, vim.bo[buf].filetype)
        if buftype or filetype then vim.opt_local.winbar = nil end
      end,
      opts = { pattern = "HeirlineInitWinbar" },
    },
  },
  {
    name = "PersistedHooks",
    {
      "User",
      function(session)
        require("persisted").save()

        -- Delete all of the open buffers
        vim.api.nvim_input("<ESC>:%bd!<CR>")

        -- Don't start saving the session yet
        require("persisted").stop()
      end,
      opts = { pattern = "PersistedTelescopeLoadPre" },
    },
  },
  {
    name = "ReturnToLastEditingPosition",
    {
      "BufReadPost",
      function()
        if vim.fn.line("'\"") > 0 and vim.fn.line("'\"") <= vim.fn.line("$") then
          vim.fn.setpos(".", vim.fn.getpos("'\""))
          vim.api.nvim_feedkeys("zz", "n", true)
          vim.cmd("silent! foldopen")
        end
      end,
    },
  },
  {
    name = "GitTrackRemoteBranch",
    {
      { "TermLeave" },
      function() om.GitRemoteSync() end,
      opts = {
        pattern = { "*" },
      },
    },
    {
      { "VimEnter" },
      function()
        local timer = vim.loop.new_timer()
        timer:start(0, 120000, function() om.GitRemoteSync() end)
      end,
      opts = {
        pattern = { "*" },
      },
    },
  },
  {
    name = "FiletypeOptions",
    {
      "FileType",
      function() vim.wo.colorcolumn = 0 end,
      opts = {
        pattern = { "oil" },
      },
    },
    {
      "FileType",
      ":setlocal shiftwidth=2 tabstop=2",
      opts = {
        pattern = { "css", "eruby", "html", "lua", "javascript", "json", "ruby", "vue" },
      },
    },
    {
      "FileType",
      ":setlocal shiftwidth=4 tabstop=4",
      opts = {
        pattern = { "ledger", "journal" },
      },
    },
    {
      "FileType",
      ":setlocal wrap linebreak",
      opts = { pattern = "markdown" },
    },
    {
      "FileType",
      ":setlocal showtabline=0",
      opts = { pattern = "alpha" },
    },
    {
      "FileType",
      --Credit:
      --https://medium.com/scoro-engineering/5-smart-mini-snippets-for-making-text-editing-more-fun-in-neovim-b55ffb96325a
      function()
        vim.keymap.set("n", "o", function()
          local line = vim.api.nvim_get_current_line()

          local should_add_comma = string.find(line, "[^,{[]$")
          if should_add_comma then
            return "A,<cr>"
          else
            return "o"
          end
        end, { buffer = true, expr = true })
      end,
      opts = { pattern = "json" },
    },
    {
      "FileType",
      function()
        vim.keymap.set("i", "=", function()
          -- The cursor location does not give us the correct node in this case, so we
          -- need to get the node to the left of the cursor
          local cursor = vim.api.nvim_win_get_cursor(0)
          local left_of_cursor_range = { cursor[1] - 1, cursor[2] - 1 }

          local node = vim.treesitter.get_node({ pos = left_of_cursor_range })
          local nodes_active_in = {
            "attribute_name",
            "directive_argument",
            "directive_name",
          }
          if not node or not vim.tbl_contains(nodes_active_in, node:type()) then
            -- The cursor is not on an attribute node
            return "="
          end

          return '=""<left>'
        end, { expr = true, buffer = true })
      end,
      opts = { pattern = { "html", "vue" } },
    },
  },
  {
    name = "QuickfixFormatting",
    {
      { "BufEnter", "WinEnter" },
      ":if &buftype == 'quickfix' | setlocal nocursorline | setlocal number | endif",
      opts = {
        pattern = { "*" },
      },
    },
  },
  {
    name = "AddRubyFiletypes",
    {
      { "BufNewFile", "BufRead" },
      ":set ft=ruby",
      opts = {
        pattern = { "*.json.jbuilder", "*.jbuilder", "*.rake" },
      },
    },
  },
  {
    name = "ChangeMappingsInTerminal",
    {
      "TermOpen",
      function()
        if vim.bo.filetype == "" or vim.bo.filetype == "toggleterm" then
          local opts = { silent = false, buffer = 0 }
          vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
          vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
        end
      end,
      opts = {
        pattern = "term://*",
      },
    },
  },
  {
    name = "RemoveWhitespaceOnSave",
    {
      { "BufWritePre" },
      [[%s/\s\+$//e]],
      opts = {
        pattern = { "*" },
      },
    },
  },
  -- Highlight text when yanked
  {
    name = "HighlightYankedText",
    {
      "TextYankPost",
      function() vim.highlight.on_yank() end,
      opts = { pattern = "*" },
    },
  },
  {
    name = "Telescope",
    {
      "User",
      ":setlocal wrap",
      opts = { pattern = "TelescopePreviewerLoaded" },
    },
  },
}
