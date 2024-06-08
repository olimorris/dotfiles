local conceal_ns = vim.api.nvim_create_namespace("ConcealClassAttribute")

---Use Legendary.nvim to create autocmds
---REF: https://github.com/mrjones2014/legendary.nvim/blob/master/doc/table_structures/AUTOCMDS.md
return {
  {
    name = "ConcealAttributes",
    {
      { "BufEnter", "BufWritePost", "TextChanged", "InsertLeave" },
      function()
        vim.opt.conceallevel = 2 -- Concealed text is completely hidden

        local bufnr = vim.api.nvim_get_current_buf()

        ---Conceal HTML class attributes. Ideal for big TailwindCSS class lists
        ---Ref: https://gist.github.com/mactep/430449fd4f6365474bfa15df5c02d27b
        local language_tree = vim.treesitter.get_parser(bufnr, "html")
        local syntax_tree = language_tree:parse()
        local root = syntax_tree[1]:root()

        local query = [[
        ((attribute
          (attribute_name) @att_name (#eq? @att_name "class")
          (quoted_attribute_value (attribute_value) @class_value) (#set! @class_value conceal "…")))
        ]]

        local ok, ts_query = pcall(vim.treesitter.query.parse, "html", query)
        if not ok then
          return print(vim.inspect(ts_query))
        end

        for _, captures, metadata in ts_query:iter_matches(root, bufnr, root:start(), root:end_(), {}) do
          local start_row, start_col, end_row, end_col = captures[2]:range()
          -- This conditional prevents conceal leakage if the class attribute is erroneously formed
          if (end_row - start_row) == 0 then
            vim.api.nvim_buf_set_extmark(bufnr, conceal_ns, start_row, start_col, {
              end_line = end_row,
              end_col = end_col,
              conceal = metadata[2].conceal,
            })
          end
        end
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
        if buftype or filetype then
          vim.opt_local.winbar = nil
        end
      end,
      opts = { pattern = "HeirlineInitWinbar" },
    },
  },
  {
    name = "PersistedHooks",
    {
      "User",
      function(session)
        -- Prompt to save the current session
        if vim.fn.confirm("Save the current session?", "&Yes\n&No") == 1 then
          require("persisted").save({ session = vim.g.persisted_loaded_session })
        end

        -- Clear all of the open buffers
        vim.api.nvim_input("silent <ESC>:%bd!<CR>")

        -- Disable automatic session saving
        require("persisted").stop()
      end,
      opts = { pattern = "PersistedTelescopeLoadPre" },
    },
    -- {
    --   "User",
    --   function(session)
    --     print(vim.inspect(session.data))
    --   end,
    --   opts = { pattern = "PersistedDeletePost" },
    -- },
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
      function()
        om.GitRemoteSync()
      end,
      opts = {
        pattern = { "*" },
      },
    },
    -- {
    --   { "VimEnter" },
    --   function()
    --     local timer = vim.loop.new_timer()
    --     timer:start(0, 120000, function()
    --       om.GitRemoteSync()
    --     end)
    --   end,
    --   opts = {
    --     pattern = { "*" },
    --   },
    -- },
  },
  {
    name = "FiletypeOptions",
    {
      "FileType",
      function()
        vim.keymap.set("n", "q", vim.cmd.close, { desc = "Close the current buffer", buffer = true })
      end,
      opts = {
        pattern = { "checkhealth", "help", "lspinfo", "netrw", "qf", "query" },
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
      ":setlocal shiftwidth=4 tabstop=4 expandtab",
      opts = {
        pattern = { "ledger", "journal" },
      },
    },
    {
      "FileType",
      ":setlocal wrap linebreak formatoptions-=t",
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
      function()
        vim.highlight.on_yank()
      end,
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
