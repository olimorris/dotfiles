local M = {}
local silent = { noremap = true, silent = true }
------------------------------------NOTES----------------------------------- {{{
--[[
  Some notes on how I structure my keymaps within Neovim:
    * All keymaps from across my configuration live in this file
    * The general structure of my keymaps are:
        1) Ctrl - Used for your most frequent and easy to remember keymaps
        2) Local Leader - Used for commands related to window or filetype/buffer options
        3) Leader - Used for commands that are global or span Neovim
    * I use legendary.nvim to set all of my mapping and display them in a floating window
]]
---------------------------------------------------------------------------- }}}
---------------------------------LEADER KEYS-------------------------------- {{{
vim.g.mapleader = " " -- space is the leader!
vim.g.maplocalleader = "\\"
---------------------------------------------------------------------------- }}}
-------------------------------DEFAULT KEYMAPS------------------------------ {{{
M.default_keymaps = function()
  local t = require("legendary.toolbox")
  local keymaps = {
    ----------------------------NEOVIM FUNCTIONALITY---------------------------- {{{
    -- Buffers
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
    { "<C-y>", "<cmd>%y+<CR>", hide = true, description = "Copy buffer" },
    { "<C-s>", "<cmd>silent! write<CR>", hide = true, description = "Save buffer", mode = { "n", "i" } },

    -- Editing words
    { "<LocalLeader>,", "<cmd>norm A,<CR>", hide = true, description = "Append comma" },
    { "<LocalLeader>;", "<cmd>norm A;<CR>", hide = true, description = "Append semicolon" },

    {
      itemgroup = "Wrap text",
      icon = "",
      description = "Wrapping text functionality",
      keymaps = {
        {
          "<LocalLeader>(",
          { n = [[ciw(<c-r>")<esc>]], v = [[c(<c-r>")<esc>]] },
          description = "Wrap text in brackets ()",
        },
        {
          "<LocalLeader>[",
          { n = [[ciw[<c-r>"]<esc>]], v = [[c[<c-r>"]<esc>]] },
          description = "Wrap text in square braces []",
        },
        {
          "<LocalLeader>{",
          { n = [[ciw{<c-r>"}<esc>]], v = [[c{<c-r>"}<esc>]] },
          description = "Wrap text in curly braces {}",
        },
        {
          '<LocalLeader>"',
          { n = [[ciw"<c-r>""<esc>]], v = [[c"<c-r>""<esc>]] },
          description = 'Wrap text in quotes ""',
        },
      },
    },

    {
      itemgroup = "Find and Replace",
      icon = "",
      description = "Find and replace within the buffer",
      keymaps = {
        {
          -- SSR plugin
          "<LocalLeader>fs",
          function() require("ssr").open() end,
          description = "Structured Find and Replace",
          mode = { "n", "x" },
        },
        {
          "<LocalLeader>fw",
          [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]],
          description = "Replace cursor words in buffer",
        },
        { "<LocalLeader>fl", [[:s/\<<C-r>=expand("<cword>")<CR>\>/]], description = "Replace cursor words in line" },
        -- {
        --   "<LocalLeader>f",
        --   ":s/{search}/{replace}/g",
        --   description = "Find and Replace (buffer)",
        --   mode = { "n", "v" },
        --   opts = { silent = false },
        -- },
      },
    },

    -- Working with lines
    { "B", "^", hide = true, description = "Beginning of a line", mode = { "n", "v" } },
    { "E", "$", hide = true, description = "End of a line", mode = { "n", "v" } },
    { "<CR>", "o<Esc>", hide = true, description = "Insert blank line below" },
    { "<S-CR>", "O<Esc>", hide = true, description = "Insert blank line above" },

    -- Splits
    { "<LocalLeader>sv", "<C-w>v", description = "Split: Vertical" },
    { "<LocalLeader>sh", "<C-w>h", description = "Split: Horizontal" },
    { "<LocalLeader>sc", "<C-w>q", description = "Split: Close" },
    { "<LocalLeader>so", "<C-w>o", description = "Split: Close all but current" },

    -- Misc
    { "<Esc>", "<cmd>:noh<CR>", description = "Clear searches" },
    { "<S-w>", ":set winbar=<CR>", description = "Hide WinBar" },
    { "<LocalLeader>U", "gUiw`", description = "Capitalize word" },
    { ">", ">gv", hide = true, description = "Indent", mode = { "v" } },
    { "<", "<gv", hide = true, description = "Outdent", mode = { "v" } },

    -- Multiple Cursors
    -- http://www.kevinli.co/posts/2017-01-19-multiple-cursors-in-500-bytes-of-vimscript/
    -- https://github.com/akinsho/dotfiles/blob/45c4c17084d0aa572e52cc177ac5b9d6db1585ae/.config/nvim/plugin/mappings.lua#L298

    -- 1. Position the cursor anywhere in the word you wish to change;
    -- 2. Or, visually make a selection;
    -- 3. Hit cn, type the new word, then go back to Normal mode;
    -- 4. Hit `.` n-1 times, where n is the number of replacements.
    {
      itemgroup = "Multiple Cursors",
      icon = "",
      description = "Working with multiple cursors",
      keymaps = {
        {
          "cn",
          {
            n = { "*``cgn" },
            x = { [[g:mc . "``cgn"]], opts = { expr = true } },
          },
          description = "Inititiate",
        },
        {
          "cN",
          {
            n = { "*``cgN" },
            x = { [[g:mc . "``cgN"]], opts = { expr = true } },
          },
          description = "Inititiate (in backwards direction)",
        },

        -- 1. Position the cursor over a word; alternatively, make a selection.
        -- 2. Hit cq to start recording the macro.
        -- 3. Once you are done with the macro, go back to normal mode.
        -- 4. Hit Enter to repeat the macro over search matches.
        {
          "cq",
          {
            n = { [[:\<C-u>call v:lua.SetupMultipleCursors()<CR>*``qz]] },
            x = { [[":\<C-u>call v:lua.SetupMultipleCursors()<CR>gv" . g:mc . "``qz"]], opts = { expr = true } },
          },
          description = "Inititiate with macros",
        },
        {
          "cQ",
          {
            n = { [[:\<C-u>call v:lua.SetupMultipleCursors()<CR>#``qz]] },
            x = {
              [[":\<C-u>call v:lua.SetupMultipleCursors()<CR>gv" . substitute(g:mc, '/', '?', 'g') . "``qz"]],
              opts = { expr = true },
            },
          },
          description = "Inititiate with macros (in backwards direction)",
        },
      },
    },
    ---------------------------------------------------------------------------- }}}
    -----------------------------------PLUGINS---------------------------------- {{{
    -- Legendary
    {
      "<C-p>",
      require("legendary").find,
      hide = true,
      description = "Open Legendary",
      mode = { "n", "v", "i" },
    },

    -- Aerial
    { "<C-t>", "<cmd>AerialToggle<CR>", hide = true, description = "Aerial" },

    -- ChatGPT
    { "<C-a>", "<cmd>ChatGPT<CR>", description = "Open ChatGPT" },

    -- Copilot
    {
      itemgroup = "Copilot",
      description = "AI programming",
      icon = "",
      keymaps = {
        {
          "<C-a>",
          function() require("copilot.suggestion").accept() end,
          description = "Accept suggestion",
          mode = { "i" },
          opts = { silent = true },
        },
        {
          "<C-x>",
          function() require("copilot.suggestion").dismiss() end,
          description = "Dismiss suggestion",
          mode = { "i" },
          opts = { silent = true },
        },
        {
          "<C-n>",
          function() require("copilot.suggestion").next() end,
          description = "Next suggestion",
          mode = { "i" },
          opts = { silent = true },
        },
        {
          "<C-\\>",
          function() require("copilot.panel").open() end,
          description = "Show Copilot panel",
          mode = { "n", "i" },
        },
      },
    },

    -- Dap
    {
      itemgroup = "Debug",
      description = "Debugging functionality",
      icon = "",
      keymaps = {
        {
          "<F1>",
          "<cmd>lua require('dap').toggle_breakpoint()<CR>",
          description = "Set breakpoint",
        },
        { "<F2>", "<cmd>lua require('dap').continue()<CR>", description = "Continue" },
        { "<F3>", "<cmd>lua require('dap').step_into()<CR>", description = "Step into" },
        { "<F4>", "<cmd>lua require('dap').step_over()<CR>", description = "Step over" },
        {
          "<F5>",
          "<cmd>lua require('dap').repl.toggle({height = 6})<CR>",
          description = "Toggle REPL",
        },
        { "<F6>", "<cmd>lua require('dap').repl.run_last()<CR>", description = "Run last" },
        {
          "<F9>",
          function()
            local _, dap = om.safe_require("dap")
            dap.disconnect()
            require("dapui").close()
          end,
          description = "Stop",
        },
      },
    },

    -- Hop
    { "s", "<cmd>lua require'hop'.hint_char1()<CR>", hide = true, description = "Hop", mode = { "n", "o" } },

    -- File Explorer
    { "<C-n>", "<cmd>Neotree toggle<CR>", hide = true, description = "Neotree: Toggle" },
    { "<C-z>", "<cmd>Neotree reveal=true toggle<CR>", hide = true, description = "Neotree: Reveal File" },

    -- Move.nvim
    {
      "<A-j>",
      { n = ":MoveLine(1)<CR>", x = ":MoveBlock(1)<CR>" },
      hide = true,
      description = "Move text down",
    },
    {
      "<A-k>",
      { n = ":MoveLine(-1)<CR>", x = ":MoveBlock(-1)<CR>" },
      hide = true,
      description = "Move text up",
    },
    {
      "<A-h>",
      { n = ":MoveHChar(-1)<CR>", x = ":MoveHBlock(-1)<CR>" },
      hide = true,
      description = "Move text left",
    },
    {
      "<A-l>",
      { n = ":MoveHChar(1)<CR>", x = ":MoveHBlock(1)<CR>" },
      hide = true,
      description = "Move text right",
    },

    -- Neotest
    {
      itemgroup = "Testing",
      icon = "省",
      description = "Testing functionality",
      keymaps = {
        -- Neotest plugin
        { "<LocalLeader>t", '<cmd>lua require("neotest").run.run()<CR>', description = "Neotest: Test nearest" },
        {
          "<LocalLeader>tf",
          '<cmd>lua require("neotest").run.run(vim.fn.expand("%"))<CR>',
          description = "Neotest: Test file",
        },
        { "<LocalLeader>tl", '<cmd>lua require("neotest").run.run_last()<CR>', description = "Neotest: Run last test" },
        {
          "<LocalLeader>ts",
          function()
            local neotest = require("neotest")
            for _, adapter_id in ipairs(neotest.run.adapters()) do
              neotest.run.run({ suite = true, adapter = adapter_id })
            end
          end,
          description = "Neotest: Test suite",
        },
        { "`", '<cmd>lua require("neotest").summary.toggle()<CR>', description = "Neotest: Toggle test summary" },
      },
    },

    -- Persisted
    {
      itemgroup = "Persisted",
      icon = "",
      description = "Session management",
      keymaps = {
        {
          "<Leader>s",
          '<cmd>lua require("persisted").toggle()<CR>',
          description = "Toggle a session",
        },
      },
    },

    -- Refactoring.nvim
    {
      itemgroup = "Refactoring",
      icon = "",
      description = "Refactor code",
      keymaps = {
        {
          "<LocalLeader>re",
          function() require("telescope").extensions.refactoring.refactors() end,
          description = "Open Refactoring.nvim",
          mode = { "n", "v", "x" },
        },
        {
          "<LocalLeader>rd",
          function() require("refactoring").debug.printf({ below = false }) end,
          description = "Insert Printf statement for debugging",
        },
        {
          "<LocalLeader>rv",
          {
            n = function() require("refactoring").debug.print_var({ normal = true }) end,
            x = function() require("refactoring").debug.print_var({}) end,
          },
          description = "Insert Print_Var statement for debugging",
          mode = { "n", "v" },
        },
        {
          "<LocalLeader>rc",
          function() require("refactoring").debug.cleanup() end,
          description = "Cleanup debug statements",
        },
      },
    },

    -- Telescope
    {
      itemgroup = "Telescope",
      description = "Gaze deeply into unknown regions using the power of the moon",
      icon = "",
      keymaps = {
        {
          "ff",
          t.lazy_required_fn("telescope.builtin", "find_files", { hidden = true }),
          description = "Find files",
        },
        { "fb", t.lazy_required_fn("telescope.builtin", "buffers"), description = "Find open buffers" },
        { "fp", "<cmd>Telescope projects<CR>", description = "Find projects" },
        {
          "<C-f>",
          t.lazy_required_fn("telescope.builtin", "current_buffer_fuzzy_find"),
          description = "Find in buffers",
        },
        {
          "<C-g>",
          t.lazy_required_fn(
            "telescope.builtin",
            "live_grep",
            { path_display = { "shorten" }, grep_open_files = true }
          ),
          description = "Find in open files",
        },
        {
          "<Leader>g",
          t.lazy_required_fn("telescope.builtin", "live_grep", { path_display = { "smart" } }),
          description = "Find in pwd",
        },
        {
          "<Leader><Leader>",
          "<cmd>lua require('telescope').extensions.frecency.frecency({ workspace = 'CWD' })<CR>",
          description = "Find recent files",
        },
      },
    },

    -- Todo comments plugin
    { "<Leader>c", "<cmd>TodoTelescope<CR>", description = "Todo comments" },

    -- Toggleterm plugin
    { "<C-x>", "<cmd>ToggleTerm<CR>", description = "Toggleterm", mode = { "n", "t" } },

    -- Treesitter Unit
    -- vau and viu select outer and inner units
    -- cau and ciu change outer and inner units
    -- vim.api.nvim_set_keymap("x", "iu", '<cmd>lua require"treesitter-unit".select()<CR>', silent)
    -- vim.api.nvim_set_keymap("x", "au", '<cmd>lua require"treesitter-unit".select(true)<CR>', silent)
    -- vim.api.nvim_set_keymap("o", "iu", '<cmd><c-u>lua require"treesitter-unit".select()<CR>', silent)
    -- vim.api.nvim_set_keymap("o", "au", '<cmd><c-u>lua require"treesitter-unit".select(true)<CR>', silent)

    -- Tmux plugin
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

    -- Undotree plugin
    { "<LocalLeader>u", "<cmd>UndotreeToggle<CR>", description = "Undotree toggle" },

    -- Yabs plugin
    {
      "<LocalLeader>d",
      "<cmd>lua require('yabs'):run_default_task()<CR>",
      description = "Build file",
    },
    ---------------------------------------------------------------------------- }}}
  }
  -- Functions for multiple cursors
  vim.g.mc = vim.api.nvim_replace_termcodes([[y/\V<C-r>=escape(@", '/')<CR><CR>]], true, true, true)

  function SetupMultipleCursors()
    vim.keymap.set(
      "n",
      "<Enter>",
      [[:nnoremap <lt>Enter> n@z<CR>q:<C-u>let @z=strpart(@z,0,strlen(@z)-1)<CR>n@z]],
      { remap = true, silent = true }
    )
  end

  return keymaps
end
---------------------------------------------------------------------------- }}}
---------------------------------COMPLETION--------------------------------- {{{
M.completion_keymaps = function()
  local _, cmp = om.safe_require("cmp")
  local _, luasnip = om.safe_require("luasnip")

  local has_words_before = function()
    if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
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
      "c",
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
      "c",
    }),
    ["<C-e>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.mapping.close()()
      else
        fallback()
      end
    end, {
      "i",
      "c",
    }),
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true, -- hitting <CR> when nothing is selected, does nothing
    }),
  }
end
---------------------------------------------------------------------------- }}}
-------------------------------------LSP------------------------------------ {{{
M.lsp_keymaps = function(client, bufnr)
  -- Do not load LSP keymaps twice
  if
    #vim.tbl_filter(
      function(keymap) return (keymap.desc or ""):lower() == "rename symbol" end,
      vim.api.nvim_buf_get_keymap(bufnr, "n")
    ) > 0
  then
    return {}
  end

  local t = require("legendary.toolbox")

  local keymaps = {
    {
      "fd",
      t.lazy_required_fn("telescope.builtin", "diagnostics", {
        layout_strategy = "vertical",
        layout_config = {
          vertical = {
            results_height = 0.5,
            prompt_position = "top",
          },
        },
        bufnr = 0,
      }),
      description = "Find diagnostics",
    },
    {
      "gi",
      "<cmd>Glance implementations<CR>",
      description = "Go to implementation",
    },
    {
      "gt",
      "<cmd>Glance type_definitions<CR>",
      description = "Go to type definition",
    },
    {
      "gd",
      "<cmd>Glance definitions<CR>",
      description = "Go to definition",
    },
    {
      "gr",
      "<cmd>Glance references<CR>",
      description = "Find references",
    },
    {
      "L",
      "<cmd>lua vim.diagnostic.open_float(0, { border = 'single', source = 'always' })<CR>",
      description = "Line diagnostics",
      opts = { buffer = bufnr },
    },
    { "H", vim.lsp.buf.hover, description = "Show hover information", opts = { buffer = bufnr } },
    {
      "<LocalLeader>p",
      t.lazy_required_fn("nvim-treesitter.textobjects.lsp_interop", "peek_definition_code", "@block.outer"),
      description = "Peek definition",
      opts = { buffer = bufnr },
    },
    { "ga", vim.lsp.buf.code_action, description = "Show code actions", opts = { buffer = bufnr } },
    { "gs", vim.lsp.buf.signature_help, description = "Show signature help", opts = { buffer = bufnr } },
    { "<leader>rn", vim.lsp.buf.rename, description = "Rename symbol", opts = { buffer = bufnr } },

    {
      "[",
      vim.diagnostic.goto_prev,
      description = "Go to previous diagnostic item",
      opts = { buffer = bufnr },
    },
    { "]", vim.diagnostic.goto_next, description = "Go to next diagnostic item", opts = { buffer = bufnr } },
  }

  table.insert(keymaps, {
    "<Leader>f",
    function() vim.lsp.buf.format({ async = true }) end,
    description = "Format document",
    opts = { buffer = bufnr },
  })

  return { itemgroup = "LSP", icon = "", description = "LSP related functionality", keymaps = keymaps }
end
---------------------------------------------------------------------------- }}}
return M
