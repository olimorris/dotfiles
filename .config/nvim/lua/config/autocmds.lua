local autocmds = {
  {
    -- Watch for changes in ~/.color_mode
    -- REF: https://github.com/rktjmp/fwatch.nvim/blob/main/lua/fwatch.lua
    name = "Colors",
    {
      "VimEnter",
      function()
        local uv = vim.uv
        local handle = uv.new_fs_event()

        local file_to_watch = "~/.color_mode"

        local flags = {
          watch_entry = false, -- true = when dir, watch dir inode, not dir content
          stat = false, -- true = don't use inotify/kqueue but periodic check, not implemented
          recursive = false, -- true = watch dirs inside dirs
        }

        local function change_colors(mode)
          -- vim.opt.background = mode or "dark"

          if mode == "light" then
            vim.cmd([[colorscheme onelight]])
          else
            vim.cmd([[colorscheme vaporwave]])
          end

          local utils = require("heirline.utils")
          utils.on_colorscheme(require("onedarkpro.helpers").get_colors())
        end

        ---Read the contents of a given file
        local function read_file(file)
          file = vim.fs.normalize(file)

          local fd = assert(uv.fs_open(file, "r", 438))
          local stat = assert(uv.fs_fstat(fd))
          local data = assert(uv.fs_read(fd, stat.size, 0))
          assert(uv.fs_close(fd))

          return vim.trim(data)
        end

        local event_cb = function(err, filename, _)
          filename = vim.fs.normalize("~/" .. filename)
          if not err then
            vim.schedule(function()
              local data = read_file(filename)
              change_colors(data)
            end)
          end
        end

        change_colors(read_file(file_to_watch))
        uv.fs_event_start(handle, vim.fs.normalize(file_to_watch), flags, event_cb)
      end,
    },
  },
  {
    name = "ConcealAttributes",
    {
      { "BufEnter", "BufWritePost", "TextChanged", "InsertLeave" },
      function()
        vim.opt.conceallevel = 2 -- Concealed text is completely hidden
      end,
      opts = {
        pattern = { "*.html" },
      },
    },
  },
  {
    name = "CodeCompanion",
    {
      "User",
      function(args)
        require("conform").format({ bufnr = args.buf })
      end,
      opts = { pattern = "CodeCompanionInlineFinished" },
    },
    -- {
    --   "User",
    --   function(args)
    --     print(vim.inspect(args))
    --   end,
    --   opts = { pattern = "CodeCompanionRequest*" },
    -- },
  },
  {
    name = "Heirline",
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
          require("persisted").save({ session = vim.g.persisting_session })
        end

        -- Clear all of the open buffers
        vim.api.nvim_input("silent <ESC>:%bd!<CR>")

        -- Disable automatic session saving
        require("persisted").stop()
      end,
      opts = { pattern = "PersistedTelescopeLoadPre" },
    },
    {
      "User",
      function()
        -- Ensure no CodeCompanion buffers are saved into the session
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.bo[buf].filetype == "codecompanion" then
            vim.api.nvim_buf_delete(buf, { force = true })
          end
        end
      end,
      opts = { pattern = "PersistedSavePre" },
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
      function()
        om.GitRemoteSync()
      end,
      opts = {
        pattern = { "*" },
      },
    },
    {
      { "VimEnter" },
      function()
        if _G.om.on_personal then
          local timer = vim.loop.new_timer()
          timer:start(0, 120000, function()
            om.GitRemoteSync()
          end)
        end
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

for _, group in ipairs(autocmds) do
  local group_name = group.name
  local augroup = vim.api.nvim_create_augroup(group_name, { clear = true })

  for _, autocmd in ipairs(group) do
    om.create_autocmd(autocmd, augroup, autocmd[2], {
      pattern = autocmd.opts and autocmd.opts.pattern or "*",
    })
  end
end
