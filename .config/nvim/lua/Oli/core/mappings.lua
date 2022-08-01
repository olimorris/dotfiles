local M = {}
local silent = { noremap = true, silent = true }
------------------------------------NOTES----------------------------------- {{{
--[[
        Some notes on how I structure my key mappings within Neovim

        * All key mappings from across my configuration live in this file
        * The general structue of my mappings are:
        	1) Ctrl - Used for your most frequent and easy to remember mappings
        	2) Local Leader - Used for commands related to filetype/buffer options
        	3) Leader - Used for commands that are global or span Neovim

        * I use legendary.nvim to set all of my mapping and display them in a
        floating window
]]
---------------------------------------------------------------------------- }}}
-----------------------------------LEADERS---------------------------------- {{{
vim.g.mapleader = " " -- space is the leader!
vim.g.maplocalleader = ","
---------------------------------------------------------------------------- }}}
-----------------------------------DEFAULTS--------------------------------- {{{
M.default_keymaps = function()
  local maps = {
    { "jk", "<esc>", description = "Escape in insert mode", mode = { "i" } },

    -- Replace selected text without yanking it
    { "p", '"_dP', description = "without ", mode = { "v" } },

    { "<Leader>qa", "<cmd>qall<CR>", description = "Quit Neovim" },
    { "<C-s>", "<cmd>silent! write<CR>", description = "Save buffer", mode = { "n", "i" } },
    { "<C-n>", "<cmd>enew<CR>", description = "New buffer" },
    { "<C-y>", "<cmd>%y+<CR>", description = "Copy buffer" },

    { "<LocalLeader>,", "<cmd>norm A,<CR>", description = "Append comma" },
    { "<LocalLeader>;", "<cmd>norm A;<CR>", description = "Append semicolon" },

    { "<LocalLeader>(", { n = [[ciw(<c-r>")<esc>]], v = [[c(<c-r>")<esc>]] }, description = "Wrap in brackets ()" },
    {
      "<LocalLeader>{",
      { n = [[ciw{<c-r>"}<esc>]], v = [[c{<c-r>"}<esc>]] },
      description = "Wrap in curly braces {}",
    },
    { '<LocalLeader>"', { n = [[ciw"<c-r>""<esc>]], v = [[c"<c-r>""<esc>]] }, description = "Wrap in quotes" },

    {
      "<LocalLeader>[",
      [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]],
      description = "Replace cursor words in buffer",
    },
    { "<LocalLeader>]", [[:s/\<<C-r>=expand("<cword>")<CR>\>/]], description = "Replace cursor words in line" },

    { "<LocalLeader>U", "gUiw`", description = "Capitalize word" },

    { "<", "<gv", description = "Outdent", mode = { "v" } },
    { ">", ">gv", description = "Indent", mode = { "v" } },

    { "<Esc>", "<cmd>:noh<CR>", description = "Clear searches" },
    -- {
    --   "<LocalLeader>f",
    --   ":s/{search}/{replace}/g",
    --   description = "Search and replace",
    --   mode = { "n", "v" },
    --   opts = { silent = false },
    -- },
    { "B", "^", description = "Beginning of a line" },
    { "E", "$", description = "End of a line" },
    { "<CR>", "o<Esc>", description = "Insert blank line below" },
    { "<S-CR>", "O<Esc>", description = "Insert blank line above" },

    { "<S-w>", ":set winbar=<CR>", description = "Hide WinBar" },

    { "<LocalLeader>sv", "<C-w>v", description = "Split: Vertical" },
    { "<LocalLeader>sh", "<C-w>h", description = "Split: Horizontal" },
    { "<LocalLeader>sc", "<C-w>q", description = "Split: Close" },
    { "<LocalLeader>so", "<C-w>o", description = "Split: Close all but current" },

    -- Multiple Cursors
    -- http://www.kevinli.co/posts/2017-01-19-multiple-cursors-in-500-bytes-of-vimscript/
    -- https://github.com/akinsho/dotfiles/blob/45c4c17084d0aa572e52cc177ac5b9d6db1585ae/.config/nvim/plugin/mappings.lua#L298

    -- 1. Position the cursor anywhere in the word you wish to change;
    -- 2. Or, visually make a selection;
    -- 3. Hit cn, type the new word, then go back to Normal mode;
    -- 4. Hit `.` n-1 times, where n is the number of replacements.
    {
      "cn",
      {
        n = { "*``cgn" },
        x = { [[g:mc . "``cgn"]], opts = { expr = true } },
      },
      description = "Multiple cursors",
    },
    {
      "cN",
      {
        n = { "*``cgN" },
        x = { [[g:mc . "``cgN"]], opts = { expr = true } },
      },
      description = "Multiple cursors (backwards)",
    },

    -- 1. Position the cursor over a word; alternatively, make a selection.
    -- 2. Hit cq to start recording the macro.
    -- 3. Once you are done with the macro, go back to normal mode.
    -- 4. Hit Enter to repeat the macro over search matches.
    {
      "cq",
      {
        n = { [[:\<C-u>call v:lua.om.mappings.setup_mc()<CR>*``qz]] },
        x = { [[":\<C-u>call v:lua.om.mappings.setup_mc()<CR>gv" . g:mc . "``qz"]], opts = { expr = true } },
      },
      description = "Multiple cursors: Macros",
    },
    {
      "cQ",
      {
        n = { [[:\<C-u>call v:lua.om.mappings.setup_mc()<CR>#``qz]] },
        x = {
          [[":\<C-u>call v:lua.as.mappings.setup_CR()<CR>gv" . substitute(g:mc, '/', '?', 'g') . "``qz"]],
          opts = { expr = true },
        },
      },
      description = "Multiple cursors: Macros (backwards)",
    },
  }

  -- Functions for multiple cursors
  vim.g.mc = vim.api.nvim_replace_termcodes([[y/\V<C-r>=escape(@", '/')<CR><CR>]], true, true, true)

  function om.mappings.setup_mc()
    vim.keymap.set(
      "n",
      "<Enter>",
      [[:nnoremap <lt>Enter> n@z<CR>q:<C-u>let @z=strpart(@z,0,strlen(@z)-1)<CR>n@z]],
      { remap = true, silent = true }
    )
  end

  -- Movement
  -- Automatically save movements larger than 5 lines to the jumplist
  -- Use Ctrl-o/Ctrl-i to navigate backwards and forwards through the jumplist
  -- vim.api.nvim_set_keymap(
  --   "n",
  --   "j",
  --   "v:count ? (v:count > 5 ? \"m'\" . v:count : '') . 'j' : 'gj'",
  --   { noremap = true, expr = true }
  -- )
  -- vim.api.nvim_set_keymap(
  --   "n",
  --   "k",
  --   "v:count ? (v:count > 5 ? \"m'\" . v:count : '') . 'k' : 'gk'",
  --   { noremap = true, expr = true }
  -- )

  return maps
end
---------------------------------------------------------------------------- }}}
-----------------------------------PLUGINS---------------------------------- {{{
-----------------------------------GENERAL---------------------------------- {{{
M.plugin_keymaps = function()
  local h = require("legendary.helpers")
  return {
    -- Legendary
    {
      "<C-p>",
      require("legendary").find,
      description = "Search keybinds and commands",
      mode = { "n", "i", "x", "v" },
    },

    -- Aerial
    { "<C-t>", "<cmd>AerialToggle<CR>", description = "Aerial" },

    -- bufdelete.nvim
    { "<C-c>", "<cmd>Bdelete<CR>", description = "Close Buffer" },

    -- Bufferline
    { "<Tab>", "<Plug>(cokeline-focus-next)", description = "Next buffer", opts = { noremap = false } },
    { "<S-Tab>", "<Plug>(cokeline-focus-prev)", description = "Previous buffer", opts = { noremap = false } },
    { "<LocalLeader>1", "<Plug>(cokeline-focus-1)", description = "Buffer focus on 1" },
    { "<LocalLeader>2", "<Plug>(cokeline-focus-2)", description = "Buffer focus on 2" },
    { "<LocalLeader>3", "<Plug>(cokeline-focus-3)", description = "Buffer focus on 3" },
    { "<LocalLeader>4", "<Plug>(cokeline-focus-4)", description = "Buffer focus on 4" },
    { "<LocalLeader>5", "<Plug>(cokeline-focus-5)", description = "Buffer focus on 5" },
    { "<LocalLeader>6", "<Plug>(cokeline-focus-6)", description = "Buffer focus on 6" },
    { "<LocalLeader>7", "<Plug>(cokeline-focus-7)", description = "Buffer focus on 7" },
    { "<LocalLeader>8", "<Plug>(cokeline-focus-8)", description = "Buffer focus on 8" },
    { "<LocalLeader>9", "<Plug>(cokeline-focus-9)", description = "Buffer focus on 9" },
    { "<Leader>1", "<Plug>(cokeline-switch-1)", description = "Buffer switch to 1" },
    { "<Leader>2", "<Plug>(cokeline-switch-2)", description = "Buffer switch to 2" },
    { "<Leader>3", "<Plug>(cokeline-switch-3)", description = "Buffer switch to 3" },
    { "<Leader>4", "<Plug>(cokeline-switch-4)", description = "Buffer switch to 4" },
    { "<Leader>5", "<Plug>(cokeline-switch-5)", description = "Buffer switch to 5" },
    { "<Leader>6", "<Plug>(cokeline-switch-6)", description = "Buffer switch to 6" },
    { "<Leader>7", "<Plug>(cokeline-switch-7)", description = "Buffer switch to 7" },
    { "<Leader>8", "<Plug>(cokeline-switch-8)", description = "Buffer switch to 8" },
    { "<Leader>9", "<Plug>(cokeline-switch-9)", description = "Buffer switch to 9" },

    -- Comments
    {
      "gcc",
      function(visual_selection)
        if visual_selection then
          require("Comment.api").locked.toggle_linewise_op(vim.fn.visualmode())
        else
          require("Comment.api").locked.toggle_current_linewise()
        end
      end,
      description = "Comment toggle",
      mode = { "n", "x" },
    },

    -- Copilot
    {
      "<C-a>",
      "copilot#Accept()",
      description = "Copilot: Accept suggestion",
      mode = { "i" },
      opts = { script = true, expr = true, silent = true },
    },
    {
      "<M-]>",
      "<Plug>(copilot-next)",
      description = "Copilot: Next",
      mode = { "i" },
      opts = { silent = true },
    },
    {
      "<M-[>",
      "<Plug>(copilot-previous)",
      description = "Copilot: Previous",
      mode = { "i" },
      opts = { silent = true },
    },
    {
      "<C-\\>",
      "<Cmd>vertical Copilot panel<CR>",
      description = "Copilot: Panel",
      mode = { "n", "i" },
    },

    -- Dap
    {
      "<F1>",
      "<cmd>lua require('dap').toggle_breakpoint()<CR>",
      description = "Debug: Set breakpoint",
    },
    { "<F2>", "<cmd>lua require('dap').continue()<CR>", description = "Debug: Continue" },
    { "<F3>", "<cmd>lua require('dap').step_into()<CR>", description = "Debug: Step into" },
    { "<F4>", "<cmd>lua require('dap').step_over()<CR>", description = "Debug: Step over" },
    {
      "<F5>",
      "<cmd>lua require('dap').repl.toggle({height = 6})<CR>",
      description = "Debug: Toggle REPL",
    },
    { "<F6>", "<cmd>lua require('dap').repl.run_last()<CR>", description = "Debug: Run last" },
    {
      "<F9>",
      function()
        local _, dap = om.safe_require("dap")
        dap.disconnect()
        dap.close()
        dap.close()
      end,
      description = "Debug: Stop",
    },

    -- Harpoon
    {
      "<LocalLeader>a",
      '<cmd>lua require("harpoon.mark").add_file()<CR>',
      description = "Harpoon: Add file",
    },
    { "<LocalLeader>b", "<cmd>Telescope harpoon marks<CR>", description = "Harpoon: List marks" },
    {
      "<LocalLeader>hn",
      '<cmd>lua require("harpoon.ui"},.nav_next()<CR>',
      description = "Harpoon: Next mark",
    },
    {
      "<LocalLeader>hp",
      '<cmd>lua require("harpoon.ui").nav_prev()<CR>',
      description = "Harpoon: Previous mark",
    },
    {
      "<LocalLeader>h1",
      '<cmd>lua require("harpoon.ui").nav_file(1)<CR>',
      description = "Harpoon: Go to 1",
    },
    {
      "<LocalLeader>h2",
      '<cmd>lua require("harpoon.ui").nav_file(2)<CR>',
      description = "Harpoon: Go to 2",
    },
    {
      "<LocalLeader>h3",
      '<cmd>lua require("harpoon.ui").nav_file(3)<CR>',
      description = "Harpoon: Go to 3",
    },
    {
      "<LocalLeader>h4",
      '<cmd>lua require("harpoon.ui").nav_file(4)<CR>',
      description = "Harpoon: Go to 4",
    },
    {
      "<LocalLeader>h5",
      '<cmd>lua require("harpoon.ui").nav_file(5)<CR>',
      description = "Harpoon: Go to 5",
    },

    --hlslens
    {
      "n",
      [[<cmd>execute('normal! ' . v:count1 . 'n')<CR><cmd>lua require('hlslens').start()<CR>]],
      description = "Next result",
    },
    {
      "N",
      [[<cmd>execute('normal! ' . v:count1 . 'N')<CR><cmd>lua require('hlslens').start()<CR>]],
      description = "Previous result",
    },

    -- Hop
    { "s", "<cmd>lua require'hop'.hint_char1()<CR>", description = "Hop", mode = { "n", "o" } },

    -- File Explorer
    { "\\", "<cmd>Neotree toggle<CR>", description = "Neotree: Toggle" },
    { "<C-z>", "<cmd>Neotree reveal %:p<CR>", description = "Neotree: Find File" },

    -- Minimap
    {
      "<LocalLeader>m",
      function()
        vim.cmd("MinimapToggle")
        vim.cmd("MinimapRefresh")
      end,
      description = "Minimap toggle",
    },

    -- Move.nvim
    {
      "<A-j>",
      { n = ":MoveLine(1)<CR>", x = ":MoveBlock(1)<CR>" },
      description = "Move text down",
    },
    {
      "<A-k>",
      { n = ":MoveLine(-1)<CR>", x = ":MoveBlock(-1)<CR>" },
      description = "Move text up",
    },
    {
      "<A-h>",
      { n = ":MoveHChar(-1)<CR>", x = ":MoveHBlock(-1)<CR>" },
      description = "Move text left",
    },
    {
      "<A-l>",
      { n = ":MoveHChar(1)<CR>", x = ":MoveHBlock(1)<CR>" },
      description = "Move text right",
    },

    -- Neotest
    { "<LocalLeader>t", '<cmd>lua require("neotest").run.run()<CR>', description = "Test nearest" },
    { "<LocalLeader>tf", '<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<CR>', description = "Test file" },
    {
      "<LocalLeader>ts",
      function()
        local neotest = require("neotest")
        for _, adapter_id in ipairs(neotest.run.adapters()) do
          neotest.run.run({ suite = true, adapter = adapter_id })
        end
      end,
      description = "Test suite",
    },
    { "`", '<cmd>lua require("neotest").summary.toggle()<CR>', description = "Toggle test summary" },

    -- Persisted
    { "<Leader>s", '<cmd>lua require("persisted").toggle()<CR>', description = "Session Toggle" },

    -- QF Helper
    -- The '!' ensures that the cursor doesn't move to the QF or LL
    { "<Leader>q", "<cmd>QFToggle!<CR>", description = "Quickfix toggle" },
    { "<Leader>l", "<cmd>LLToggle!<CR>", description = "Location List toggle" },

    -- Refactoring.nvim
    {
      "<LocalLeader>re",
      function()
        require("telescope").extensions.refactoring.refactors()
      end,
      description = "Refactoring",
      mode = { "n", "v", "x" },
    },
    {
      "<LocalLeader>rd",
      function()
        require("refactoring").debug.printf({ below = false })
      end,
      description = "Refactoring: Printf",
    },
    {
      "<LocalLeader>rv",
      function(visual_selection)
        if visual_selection then
          require("refactoring").debug.print_var({})
        else
          require("refactoring").debug.print_var({ normal = true })
        end
      end,
      description = "Refactoring: Print_Var",
      mode = { "n", "v" },
    },
    {
      "<LocalLeader>rc",
      function()
        require("refactoring").debug.cleanup()
      end,
      description = "Refactoring: Cleanup",
    },

    -- Search
    {
      "//",
      function(visual_selection)
        if visual_selection then
          require("searchbox").match_all({ visual_mode = true })
        else
          require("searchbox").match_all()
        end
      end,
      description = "Search",
      mode = { "n", "x" },
    },
    {
      "<LocalLeader>r",
      function(visual_selection)
        if visual_selection then
          vim.cmd(":'<,'>SearchBoxReplace visual_mode=true")
        else
          vim.cmd(":SearchBoxReplace")
        end
      end,
      description = "Search and replace",
      mode = { "n", "x" },
    },

    -- Telescope
    { "fd", h.lazy_required_fn("telescope.builtin", "diagnostics", { bufnr = 0 }), description = "Find diagnostics" },
    {
      "ff",
      h.lazy_required_fn("telescope.builtin", "find_files", { hidden = true }),
      description = "Find files",
    },
    { "fb", h.lazy_required_fn("telescope.builtin", "buffers"), description = "Find open buffers" },
    { "fp", "<cmd>Telescope project display_type=full<CR>", description = "Find projects" },
    {
      "<C-f>",
      h.lazy_required_fn("telescope.builtin", "current_buffer_fuzzy_find"),
      description = "Find in buffers",
    },
    {
      "<C-g>",
      h.lazy_required_fn("telescope.builtin", "live_grep", { path_display = { "shorten" }, grep_open_files = true }),
      description = "Find in open files",
    },
    {
      "<Leader>g",
      h.lazy_required_fn("telescope.builtin", "live_grep", { path_display = { "smart" } }),
      description = "Find in pwd",
    },
    {
      "<Leader><Leader>",
      "<cmd>lua require('telescope').extensions.frecency.frecency()<CR>",
      description = "Find recent files",
    },

    -- Textobj diagnostics
    {
      "]d",
      function()
        require("textobj-diagnostic").next_diag_inclusive({
          severity = {
            min = vim.diagnostic.severity.WARN,
            max = vim.diagnostic.severity.ERROR,
          },
        })
      end,
      description = "Select next diagnostic",
      mode = { "x", "o" },
    },
    {
      "[d",
      function()
        require("textobj-diagnostic").prev_diag({
          severity = {
            min = vim.diagnostic.severity.WARN,
            max = vim.diagnostic.severity.ERROR,
          },
        })
      end,
      description = "Select previous diagnostic",
      mode = { "x", "o" },
    },

    -- Todo comments
    { "<Leader>c", "<cmd>TodoTelescope<CR>", description = "Todo comments" },

    -- Toggleterm
    { "<C-x>", "<cmd>ToggleTerm<CR>", description = "Toggleterm", mode = { "n", "t" } },

    -- Treesitter Unit
    -- vau and viu select outer and inner units
    -- cau and ciu change outer and inner units
    -- vim.api.nvim_set_keymap("x", "iu", '<cmd>lua require"treesitter-unit".select()<CR>', silent)
    -- vim.api.nvim_set_keymap("x", "au", '<cmd>lua require"treesitter-unit".select(true)<CR>', silent)
    -- vim.api.nvim_set_keymap("o", "iu", '<cmd><c-u>lua require"treesitter-unit".select()<CR>', silent)
    -- vim.api.nvim_set_keymap("o", "au", '<cmd><c-u>lua require"treesitter-unit".select(true)<CR>', silent)

    -- Tmux
    {
      "<C-k>",
      "<cmd>lua require('tmux').move_up()<CR>",
      description = "Tmux: Move up",
    },
    {
      "<C-j>",
      "<cmd>lua require('tmux').move_down()<CR>",
      description = "Tmux: Move down",
    },
    {
      "<C-h>",
      "<cmd>lua require('tmux').move_left()<CR>",
      description = "Tmux: Move left",
    },
    {
      "<C-l>",
      "<cmd>lua require('tmux').move_right()<CR>",
      description = "Tmux: Move right",
    },

    -- Undotree
    { "<LocalLeader>u", "<cmd>UndotreeToggle<CR>", description = "Undotree toggle" },

    -- Yabs
    {
      "<LocalLeader>d",
      "<cmd>lua require('yabs'):run_default_task()<CR>",
      description = "Build file",
    },
  }
end
---------------------------------------------------------------------------- }}}
---------------------------------COMPLETION--------------------------------- {{{
M.completion_keymaps = function()
  local _, cmp = om.safe_require("cmp")
  local _, luasnip = om.safe_require("luasnip")

  local has_words_before = function()
    local line, col = table.unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
  end

  return {
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
    ["<C-e>"] = cmp.mapping.close(),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<CR>"] = cmp.mapping.confirm({
      select = true, -- hitting <CR> when nothing is selected, does nothing
    }),
  }
end
---------------------------------------------------------------------------- }}}
-------------------------------------LSP------------------------------------ {{{
M.lsp_keymaps = function(client, bufnr)
  local h = require("legendary.helpers")
  local maps = {}

  if client.name ~= "null-ls" then
    maps = {
      { "gd", vim.lsp.buf.definition, description = "LSP: Go to definition", opts = { buffer = bufnr } },
      {
        "gr",
        h.lazy_required_fn("telescope.builtin", "lsp_references"),
        description = "LSP: Find references",
        opts = { buffer = bufnr },
      },
      {
        "L",
        "<cmd>lua vim.diagnostic.open_float(0, { border = 'single', source = 'always' })<CR>",
        description = "LSP: Line diagnostics",
        mode = { "n", "x" },
      },
      { "gh", vim.lsp.buf.hover, description = "LSP: Show hover information", opts = { buffer = bufnr } },
      {
        "<LocalLeader>p",
        h.lazy_required_fn("nvim-treesitter.textobjects.lsp_interop", "peek_definition_code", "@block.outer"),
        description = "LSP: Peek definition",
        opts = { buffer = bufnr },
      },
      { "F", vim.lsp.buf.code_action, description = "LSP: Show code actions", opts = { buffer = bufnr } },
      {
        "[",
        vim.diagnostic.goto_prev,
        description = "LSP: Go to previous diagnostic item",
        opts = { buffer = bufnr },
      },
      { "]", vim.diagnostic.goto_next, description = "LSP: Go to next diagnostic item", opts = { buffer = bufnr } },
    }
  end

  if client.name ~= "null-ls" and client.server_capabilities.implementation then
    table.insert(maps, {
      "gi",
      vim.lsp.buf.implementation,
      description = "LSP: Go to implementation",
      opts = { buffer = bufnr },
    })
  end
  if client.name ~= "null-ls" and client.server_capabilities.type_definition then
    table.insert(
      maps,
      { "gt", vim.lsp.buf.type_definition, description = "LSP: Go to type definition", opts = { buffer = bufnr } }
    )
  end
  if client.name ~= "null-ls" and client.supports_method("textDocument/rename") then
    table.insert(
      maps,
      { "<leader>rn", vim.lsp.buf.rename, description = "LSP: Rename symbol", opts = { buffer = bufnr } }
    )
  end
  if client.name ~= "null-ls" and client.supports_method("textDocument/signatureHelp") then
    table.insert(
      maps,
      { "gs", vim.lsp.buf.signature_help, description = "LSP: Show signature help", opts = { buffer = bufnr } }
    )
  end

  local lsps_that_can_format = { ["null-ls"] = true }

  if om.contains(lsps_that_can_format, client.name) and client.server_capabilities.documentFormattingProvider then
    table.insert(maps, {
      "<LocalLeader>lf",
      function()
        vim.b.format_changedtick = vim.b.changedtick
        vim.lsp.buf.format({ async = true })
      end,
      description = "LSP: Format",
      opts = { buffer = bufnr },
    })
  else
    client.server_capabilities.documentFormattingProvider = false
  end

  -- Trouble.nvim
  table.insert(maps, {
    "T",
    "<cmd>TroubleToggle<CR>",
    description = "LSP: Trouble",
  })

  return maps
end
---------------------------------------------------------------------------- }}}
---------------------------------------------------------------------------- }}}
return M
