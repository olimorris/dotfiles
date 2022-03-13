local M = {}
local silent = { noremap = true, silent = true }
local noisy = { noremap = true, silent = false }
------------------------------------NOTES----------------------------------- {{{
--[[
        Some notes on how I structure my key mappings within Neovim

        * All key mappings from across my configuration live in this file
        * The general structue of my mappings are:
        	1) Ctrl - Used for your most frequent and easy to remember mappings
        	2) Local Leader - Used for commands related to filetype/buffer options
        	3) Leader - Used for commands that are global or span Neovim

        * The which-key.nvim plugin is used as a popup to remind me of possible
        key bindings. Pressing either the Leader or Local Leader key will result
        in which-key appearing
]]
---------------------------------------------------------------------------- }}}
-----------------------------------LEADERS---------------------------------- {{{
vim.g.mapleader = " " -- space is the leader!
vim.g.maplocalleader = ","
---------------------------------------------------------------------------- }}}
-----------------------------------NEOVIM----------------------------------- {{{
M.neovim = function()
  vim.api.nvim_set_keymap("i", "jk", "<esc>", silent) -- Easy escape in insert mode
  vim.api.nvim_set_keymap("n", "<Leader>qa", "<cmd>qall<CR>", silent) -- Easy quit
  vim.api.nvim_set_keymap("n", "<C-s>", "<cmd>silent! write<CR>", silent) -- Easy save

  vim.api.nvim_set_keymap("n", "<c-n>", "<cmd>enew<CR>", silent) -- New buffer
  vim.api.nvim_set_keymap("n", "<c-y>", "<cmd>%y+<CR>", silent) -- Copy the whole file

  -- Appending to end of lines
  vim.api.nvim_set_keymap("n", "<LocalLeader>,", "<cmd>norm A,<CR>", silent) -- Comma
  vim.api.nvim_set_keymap("n", "<LocalLeader>;", "<cmd>norm A;<CR>", silent) -- Semicolon

  -- Wrapping lines
  vim.api.nvim_set_keymap("n", "<LocalLeader>(", [[ciw(<c-r>")<esc>]], silent) -- Wrap in ()
  vim.api.nvim_set_keymap("v", "<LocalLeader>(", [[c(<c-r>")<esc>]], silent) -- Wrap in ()

  vim.api.nvim_set_keymap("n", "<LocalLeader>{", [[ciw{<c-r>"}<esc>]], silent) -- Wrap in {}
  vim.api.nvim_set_keymap("v", "<LocalLeader>{", [[c{<c-r>"}<esc>]], silent) -- Wrap in {}

  vim.api.nvim_set_keymap("n", '<LocalLeader>"', [[ciw"<c-r>""<esc>]], silent) -- Wrap in ""
  vim.api.nvim_set_keymap("v", '<LocalLeader>"', [[c"<c-r>""<esc>]], silent) -- Wrap in ""

  -- Replace cursor words
  vim.api.nvim_set_keymap("n", "<LocalLeader>[", [[:%s/\<<C-r>=expand("<cword>")<CR>\>/]], noisy) -- File
  vim.api.nvim_set_keymap("n", "<LocalLeader>]", [[:s/\<<C-r>=expand("<cword>")<CR>\>/]], noisy) -- Line

  -- Capitalize word
  vim.api.nvim_set_keymap("n", "<LocalLeader>U", "gUiw`]", silent)

  -- Shift words in visual mode
  vim.api.nvim_set_keymap("v", "<", "<gv", silent)
  vim.api.nvim_set_keymap("v", ">", ">gv", silent)

  -- Finding and highlighting values
  -- vim.api.nvim_set_keymap('n', '<C-f>', ' :/')
  vim.api.nvim_set_keymap("n", "<Esc>", "<Esc>:noh<CR>", silent)
  vim.api.nvim_set_keymap("v", "<LocalLeader>f", " :s/{search}/{replace}/g", {})
  vim.api.nvim_set_keymap("n", "<LocalLeader>f", " :%s/{search}/{replace}/g", {})

  -- Movement
  -- Automatically save movements larger than 5 lines to the jumplist
  -- Use Ctrl-o/Ctrl-i to navigate backwards and forwards through the jumplist
  vim.api.nvim_set_keymap(
    "n",
    "j",
    "v:count ? (v:count > 5 ? \"m'\" . v:count : '') . 'j' : 'gj'",
    { noremap = true, expr = true }
  )
  vim.api.nvim_set_keymap(
    "n",
    "k",
    "v:count ? (v:count > 5 ? \"m'\" . v:count : '') . 'k' : 'gk'",
    { noremap = true, expr = true }
  )

  vim.api.nvim_set_keymap("n", "B", "^", silent) -- Beginning of a line
  vim.api.nvim_set_keymap("n", "E", "$", silent) -- End of a line

  vim.api.nvim_set_keymap("n", "<CR>", "o<Esc>", silent) -- Insert blank line without entering insert mode

  -- Allow using of the alt key
  vim.api.nvim_set_keymap("n", "¬", "<a-l>", silent)
  vim.api.nvim_set_keymap("n", "˙", "<a-h>", silent)
  vim.api.nvim_set_keymap("n", "∆", "<a-j>", silent)
  vim.api.nvim_set_keymap("n", "˚", "<a-k>", silent)

  -- Move lines of code up or down
  vim.api.nvim_set_keymap("n", "∆", "<cmd>move+<CR>==", silent)
  vim.api.nvim_set_keymap("n", "˚", "<cmd>move-2<CR>==", silent)
  vim.api.nvim_set_keymap("v", "∆", ":move'>+<CR>='[gv", silent)
  vim.api.nvim_set_keymap("v", "˚", ":move-2<CR>='[gv", silent)

  vim.api.nvim_set_keymap("v", "<", "<gv", {}) -- Reselect the visual block after indent
  vim.api.nvim_set_keymap("v", ">", ">gv", {}) -- Reselect the visual block after outdent

  -- Splits
  -- INFO: Some of these have been replaced by the use of focus.nvim
  vim.api.nvim_set_keymap("n", "<LocalLeader>sc", "<C-w>q", {}) -- Close the current split
  vim.api.nvim_set_keymap("n", "<LocalLeader>so", "<C-w>o", {}) -- Close all splits but the current one

  -- Tabs
  -- vim.api.nvim_set_keymap("n", "<Leader>te", "<cmd>tabe %<CR>", silent)
  -- vim.api.nvim_set_keymap("n", "<Leader>to", "<cmd>tabonly<CR>", silent)
  -- vim.api.nvim_set_keymap("n", "<Leader>tc", "<cmd>tabclose<CR>", silent)

  -- Next tab is gt
  -- Previous tab is gT

  -- Terminal mode
  vim.api.nvim_set_keymap("t", "jk", "<C-\\><C-n>", silent) -- Easy escape in terminal mode
  vim.api.nvim_set_keymap("t", "<esc>", "<C-\\><C-n>", {}) -- Escape in the terminal closes it
  vim.api.nvim_set_keymap("t", ":q!", "<C-\\><C-n>:q!<CR>", {}) -- In the terminal :q quits it

  -- Misc
  vim.api.nvim_set_keymap("n", "<Leader>r", "<cmd>call v:lua.ReloadConfig()<CR>", silent)

  -- Multiple cursors
  -- http://www.kevinli.co/posts/2017-01-19-multiple-cursors-in-500-bytes-of-vimscript/
  -- https://github.com/akinsho/dotfiles/blob/45c4c17084d0aa572e52cc177ac5b9d6db1585ae/.config/nvim/plugin/mappings.lua#L298

  -- 1. Position the cursor anywhere in the word you wish to change;
  -- 2. Hit cn, type the new word, then go back to Normal mode;
  -- 3. Hit . n-1 times, where n is the number of replacements.
  vim.api.nvim_set_keymap("n", "cn", "*``cgn", silent) -- Changing a word
  vim.api.nvim_set_keymap("n", "cN", "*``cgN", silent) -- Changing a word (in backwards direction)

  -- 1. Position the cursor over a word; alternatively, make a selection.
  -- 2. Hit cq to start recording the macro.
  -- 3. Once you are done with the macro, go back to normal mode.
  -- 4. Hit Enter to repeat the macro over search matches.
  function om.mappings.setup_mc()
    vim.api.nvim_set_keymap(
      "n",
      "<Enter>",
      [[:nnoremap <lt>Enter> n@z<CR>q:<C-u>let @z=strpart(@z,0,strlen(@z)-1)<CR>n@z]],
      { noremap = false, silent = true }
    )
  end
  vim.g.mc = [[y/\\V\<C-r>=escape(@\", '/')\<CR>\<CR>]]
  vim.api.nvim_set_keymap("x", "cn", [[g:mc . "``cgn"]], { expr = true, silent = true })
  vim.api.nvim_set_keymap("x", "cN", [[g:mc . "``cgN"]], { expr = true, silent = true })
  vim.api.nvim_set_keymap("n", "cq", [[:lua om.mappings.setup_mc()<CR>*``qz]], { noremap = true, silent = true })
  vim.api.nvim_set_keymap("n", "cQ", [[:lua om.mappings.setup_mc()<CR>#``qz]], { noremap = true, silent = true })
  vim.api.nvim_set_keymap(
    "x",
    "cq",
    [[":\<C-u>lua om.mappings.setup_mc()\<CR>" . "gv" . g:mc . "``qz"]],
    { expr = true }
  )
end
---------------------------------------------------------------------------- }}}
-----------------------------------PLUGINS---------------------------------- {{{
M.aerial = function()
  vim.api.nvim_set_keymap("n", "<C-t>", "<cmd>AerialToggle<CR>", silent)
end

M.bufdelete = function()
  vim.api.nvim_set_keymap("n", "<C-c>", "<cmd>Bwipeout!<CR>", silent)
end

M.bufferline = function()
  -- noremap with <Plug> doesn't work!
  vim.api.nvim_set_keymap("n", "<Tab>", "<Plug>(cokeline-focus-next)", { noremap = false })
  vim.api.nvim_set_keymap("n", "<S-Tab>", "<Plug>(cokeline-focus-prev)", { noremap = false })

  for i = 1, 9 do
    -- Navigate to a buffer with a given index of i
    vim.api.nvim_set_keymap(
      "n",
      ("<Localleader>%s"):format(i),
      ("<Plug>(cokeline-focus-%s)"):format(i),
      { silent = true }
    )
    -- Switch a buffer with another buffer with a given index of i
    vim.api.nvim_set_keymap("n", ("<Leader>%s"):format(i), ("<Plug>(cokeline-switch-%s)"):format(i), { silent = true })
  end
end

M.cryptoprice = function()
  vim.api.nvim_set_keymap("n", "<LocalLeader>c", "<cmd>lua require('cryptoprice').toggle()<CR>", silent)
end

M.dap = function()
  vim.api.nvim_set_keymap("n", "<F1>", "<cmd>lua require('dap').toggle_breakpoint()<CR>", silent)
  vim.api.nvim_set_keymap("n", "<F2>", "<cmd>lua require('dap').continue()<CR>", silent)
  vim.api.nvim_set_keymap("n", "<F3>", "<cmd>lua require('dap').step_into()<CR>", silent)
  vim.api.nvim_set_keymap("n", "<F4>", "<cmd>lua require('dap').step_over()<CR>", silent)
  vim.api.nvim_set_keymap("n", "<F5>", "<cmd>lua require('dap').repl.toggle({height = 6})<CR>", silent)
  vim.api.nvim_set_keymap("n", "<F9>", "<cmd>lua require('dap').repl.run_last()<CR>", silent)

  function DapStop()
    local _, dap = om.safe_require("dap")
    dap.disconnect()
    dap.close()
    dap.close()
  end
  vim.api.nvim_set_keymap("n", "<F6>", "<cmd>call v:lua.DapStop()<CR>", {})
end

M.harpoon = function()
  vim.api.nvim_set_keymap("n", "<LocalLeader>ha", '<cmd>lua require("harpoon.mark").add_file()<CR>', silent)
  vim.api.nvim_set_keymap("n", "<LocalLeader>hl", "<cmd>Telescope harpoon marks<CR>", silent)
  vim.api.nvim_set_keymap("n", "<LocalLeader>hn", '<cmd>lua require("harpoon.ui").nav_next()<CR>', silent)
  vim.api.nvim_set_keymap("n", "<LocalLeader>hp", '<cmd>lua require("harpoon.ui").nav_prev()<CR>', silent)
  vim.api.nvim_set_keymap("n", "<LocalLeader>h1", '<cmd>lua require("harpoon.ui").nav_file(1)<CR>', silent)
  vim.api.nvim_set_keymap("n", "<LocalLeader>h1", '<cmd>lua require("harpoon.ui").nav_file(1)<CR>', silent)
  vim.api.nvim_set_keymap("n", "<LocalLeader>h2", '<cmd>lua require("harpoon.ui").nav_file(2)<CR>', silent)
  vim.api.nvim_set_keymap("n", "<LocalLeader>h3", '<cmd>lua require("harpoon.ui").nav_file(3)<CR>', silent)
  vim.api.nvim_set_keymap("n", "<LocalLeader>h4", '<cmd>lua require("harpoon.ui").nav_file(4)<CR>', silent)
  vim.api.nvim_set_keymap("n", "<LocalLeader>h5", '<cmd>lua require("harpoon.ui").nav_file(5)<CR>', silent)
end

M.hop = function()
  vim.api.nvim_set_keymap("n", "s", "<cmd>HopChar1<CR>", silent)
  vim.api.nvim_set_keymap("o", "s", "<cmd>HopChar1<CR>", silent)

  -- Override f/F keys
  vim.api.nvim_set_keymap(
    "n",
    "f",
    "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true })<cr>",
    opts
  )
  vim.api.nvim_set_keymap(
    "n",
    "F",
    "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true })<cr>",
    opts
  )
  vim.api.nvim_set_keymap(
    "o",
    "f",
    "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.AFTER_CURSOR, current_line_only = true, inclusive_jump = true })<cr>",
    opts
  )
  vim.api.nvim_set_keymap(
    "o",
    "F",
    "<cmd>lua require'hop'.hint_char1({ direction = require'hop.hint'.HintDirection.BEFORE_CURSOR, current_line_only = true, inclusive_jump = true })<cr>",
    opts
  )
end

M.file_explorer = function()
  vim.api.nvim_set_keymap("n", "\\", "<cmd>NvimTreeToggle<CR>", { silent = true })
  vim.api.nvim_set_keymap("n", "<C-z>", "<cmd>NvimTreeFindFile<CR>", { silent = true })
end

M.focus = function()
  local focusmap = function(direction)
    vim.api.nvim_set_keymap(
      "n",
      "<LocalLeader>s" .. direction,
      "<cmd>lua require('focus').split_command('" .. direction .. "')<CR>",
      silent
    )
  end
  -- Use `<LocalLeader>sh` to split the screen to the left, same as command FocusSplitLeft etc
  focusmap("h")
  focusmap("j")
  focusmap("k")
  focusmap("l")

  vim.api.nvim_set_keymap("n", "<LocalLeader>ss", "<cmd>lua pcall(require('focus').split_nicely())<CR>", silent)
end

M.lsp = function(client, bufnr)
  local maps = {
    ["<LocalLeader>lD"] = { vim.lsp.buf.declaration, "Declaration" },
    ["<LocalLeader>ld"] = { vim.lsp.buf.definition, "Definition" },
    ["<LocalLeader>lr"] = { vim.lsp.buf.references, "References" },
    ["<LocalLeader>lI"] = { vim.lsp.buf.incoming_calls, "Incoming calls" },
    ["L"] = {
      "<cmd>lua vim.diagnostic.open_float(0, { border = 'single', source = 'always' })<CR>",
      "Line diagnostics",
    },
    ["K"] = { vim.lsp.buf.hover, "Hover" },
  }

  if client.resolved_capabilities.implementation then
    maps["<LocalLeader>li"] = { vim.lsp.buf.implementation, "Implementation" }
  end
  if client.resolved_capabilities.type_definition then
    maps["<LocalLeader>lt"] = {
      vim.lsp.buf.type_definition,
      "Type definition",
    }
  end
  if client.supports_method("textDocument/rename") then
    maps["<LocalLeader>ln"] = { vim.lsp.buf.rename, "Rename" }
  end
  if client.supports_method("textDocument/signatureHelp") then
    maps["<LocalLeader>ls"] = { vim.lsp.buf.signature_help, "Signature help" }
  end

  maps["<LocalLeader>l["] = {
    function()
      vim.diagnostic.goto_prev({
        float = {
          border = "rounded",
          focusable = false,
          source = "always",
        },
      })
    end,
    "Previous diagnostic",
  }
  maps["<LocalLeader>l]"] = {
    function()
      vim.diagnostic.goto_next({
        float = {
          border = "rounded",
          focusable = false,
          source = "always",
        },
      })
    end,
    "Next diagnostic",
  }

  local ok, lightbulb = om.safe_require("nvim-lightbulb")
  if ok then
    lightbulb.setup({
      sign = {
        enabled = false,
      },
      float = {
        enabled = true,
      },
    })
    om.augroup("LspCodeAction", {
      {
        events = { "CursorHold", "CursorHoldI" },
        targets = { "<buffer>" },
        command = function()
          lightbulb.update_lightbulb()
        end,
      },
    })
  end
  maps["<LocalLeader>lc"] = {
    vim.lsp.buf.range_code_action,
    "Code action",
  }
  if client and client.resolved_capabilities.code_lens then
    om.augroup("LspCodeLens", {
      {
        events = { "BufEnter", "CursorHold", "InsertLeave" },
        targets = { "<buffer>" },
        command = vim.lsp.codelens.refresh,
      },
    })
  end
  if client and client.resolved_capabilities.document_highlight then
    om.augroup("LspDocumentHighlight", {
      {
        events = { "CursorHold", "CursorHoldI" },
        targets = { "<buffer>" },
        command = vim.lsp.buf.document_highlight,
      },
      {
        events = { "CursorMoved" },
        targets = { "<buffer>" },
        command = vim.lsp.buf.clear_references,
      },
    })
  end
  -- List of LSP servers that we allow to format
  local lsps_that_can_format = { ["null-ls"] = true, solargraph = true }

  if om.contains(lsps_that_can_format, client.name) and client.resolved_capabilities.document_formatting then
    -- om.augroup("LspFormat", {
    --     {
    --         events = { "BufWritePre" },
    --         targets = { "<buffer>" },
    --         command = vim.lsp.buf.formatting_sync,
    --     },
    -- })
    maps["<localleader>lf"] = { vim.lsp.buf.formatting, "Format" }
  else
    client.resolved_capabilities.document_formatting = false
  end
  -- Register our key bindings with which-key
  require("which-key").register(maps, { buffer = 0 })
end

M.marks = function()
  --[[ Notes:
	mx              Set mark x
    m,              Set the next available alphabetical (lowercase) mark
    m;              Toggle the next available mark at the current line
    dmx             Delete mark x
    dm-             Delete all marks on the current line
    dm<space>       Delete all marks in the current buffer
    m]              Move to next mark
    m[              Move to previous mark
    m:              Preview mark. This will prompt you for a specific mark to
                    preview; press <cr> to preview the next mark.

	Only configured for Bookmark 0:
    m[0-9]          Add a bookmark from bookmark group[0-9].
    dm[0-9]         Delete all bookmarks from bookmark group[0-9].

    m}              Move to the next bookmark having the same type as the bookmark under
                    the cursor. Works across buffers.
    m{              Move to the previous bookmark having the same type as the bookmark under
                    the cursor. Works across buffers.
    dm=             Delete the bookmark under the cursor.
	--]]

  local ok, marks = om.safe_require("marks")
  if not ok then
    return
  end

  marks.setup({
    mappings = {
      -- Marks
      delete = "mxx", -- Delete a letter mark
      delete_buf = "mxb", -- Delete all marks in the buffer
      delete_line = "md", -- Delete all marks on the line

      next = "m]", -- Go to the next mark
      prev = "m[", -- Go to the previous mark
      preview = "mp", -- Preview the mark (enter the mark name or press <cr>)
      set = "ms", -- Set a mark
      set_next = "m,", -- Set the next available lowercase mark
      toggle = "mm", -- Toggle the next available mark

      -- Bookmarks
      set_bookmark0 = "mbs0",
      set_bookmark1 = "mbs1",
      set_bookmark2 = "mbs2",
      set_bookmark3 = "mbs3",
      set_bookmark4 = "mbs4",
      set_bookmark5 = "mbs5",
      set_bookmark6 = "mbs6",
      set_bookmark7 = "mbs7",
      set_bookmark8 = "mbs8",
      set_bookmark9 = "mbs9",
      delete_bookmark = "mbd",
      delete_bookmark0 = "mbx0",
      delete_bookmark1 = "mbx1",
      delete_bookmark2 = "mbx2",
      delete_bookmark3 = "mbx3",
      delete_bookmark4 = "mbx4",
      delete_bookmark5 = "mbx5",
      delete_bookmark6 = "mbx6",
      delete_bookmark7 = "mbx7",
      delete_bookmark8 = "mbx8",
      delete_bookmark9 = "mbx9",
      next_bookmark = "mb]",
      prev_bookmark = "mb[",
      annotate = "mba",
    },
  })
end

M.minimap = function()
  vim.api.nvim_set_keymap("n", "<LocalLeader>m", "<cmd>MinimapToggle<CR><cmd>MinimapRefresh<CR>", silent)
end

M.neoclip = function()
  vim.api.nvim_set_keymap(
    "n",
    "<LocalLeader>p",
    "<cmd>lua require('telescope').extensions.neoclip.default()<CR>",
    silent
  )
end

M.packer = function()
  om.command({
    "PC",
    function()
      require(config_namespace .. ".core.plugins")
      require("packer").compile()
    end,
  })
  om.command({
    "PCL",
    function()
      require(config_namespace .. ".core.plugins")
      require("packer").clean()
    end,
  })
  om.command({
    "PI",
    function()
      require(config_namespace .. ".core.plugins")
      require("packer").install()
    end,
  })
  om.command({
    "PS",
    function()
      require(config_namespace .. ".core.plugins")
      require("packer").sync()
    end,
  })
  om.command({
    "PST",
    function()
      require(config_namespace .. ".core.plugins")
      require("packer").status()
    end,
  })
  om.command({
    "PU",
    function()
      require(config_namespace .. ".core.plugins")
      require("packer").update()
    end,
  })
end

M.persisted = function()
  vim.api.nvim_set_keymap("n", "<Leader>s", '<cmd>lua require("persisted").toggle()<CR>', silent)
end

M.qf_helper = function()
  -- The '!' ensures that the cursor doesn't move to the QF or LL
  vim.api.nvim_set_keymap("n", "<Leader>q", "<cmd>QFToggle!<CR>", silent)
  vim.api.nvim_set_keymap("n", "<Leader>l", "<cmd>LLToggle!<CR>", silent)
end

M.search = function()
  vim.api.nvim_set_keymap("n", "/", '<cmd>lua require("searchbox").match_all()<CR>', silent)
  vim.api.nvim_set_keymap("v", "/", '<cmd>lua require("searchbox").match_all()<CR>', silent)

  vim.api.nvim_set_keymap("n", "<LocalLeader>r", '<cmd>lua require("searchbox").replace()<CR>', silent)
  vim.api.nvim_set_keymap("v", "<LocalLeader>r", '<cmd>lua require("searchbox").replace()<CR>', silent)
end

M.telescope = function()
  vim.api.nvim_set_keymap("n", "T", "<cmd>Telescope diagnostics bufnr=0 <CR>", silent)

  vim.api.nvim_set_keymap(
    "n",
    "<C-p>",
    "<cmd>lua require('telescope.builtin').find_files({hidden=true,path_display=smart}) <CR>",
    silent
  )
  vim.api.nvim_set_keymap("n", "<C-f>", "<cmd>Telescope current_buffer_fuzzy_find <CR>", silent)
  vim.api.nvim_set_keymap("n", "<Leader>p", "<cmd>Telescope project display_type=full <CR>", silent)
  vim.api.nvim_set_keymap(
    "n",
    "<Leader>e",
    "<cmd>lua require('telescope.builtin').find_files({prompt_title='Neovim Config',cwd='~/.config/nvim/lua'})<CR>",
    silent
  )
  vim.api.nvim_set_keymap(
    "n",
    "<C-g>",
    "<cmd>Telescope live_grep path_display=shorten grep_open_files=true<CR>",
    silent
  )
  -- vim.api.nvim_set_keymap("n", "<C-t>", "<cmd>Telescope treesitter<CR>", silent)
  vim.api.nvim_set_keymap(
    "n",
    "<Leader><Leader>",
    "<cmd>lua require('telescope').extensions.frecency.frecency()<CR>",
    silent
  )
  vim.api.nvim_set_keymap("n", "<Leader>g", "<cmd>Telescope live_grep path_display=smart<CR>", silent)
end

M.todo_comments = function()
  vim.api.nvim_set_keymap("n", "<Leader>c", "<cmd>TodoTelescope<CR>", silent)
end

M.toggleterm = function()
  vim.api.nvim_set_keymap("n", "<C-x>", "<cmd>ToggleTerm<CR>", silent)
  vim.api.nvim_set_keymap("t", "<C-x>", "<cmd>ToggleTerm<CR>", silent)
end

M.treesitter = function()
  -- Treesitter Unit
  -- vau and viu select outer and inner units
  -- cau and ciu change outer and inner units
  vim.api.nvim_set_keymap("x", "iu", '<cmd>lua require"treesitter-unit".select()<CR>', silent)
  vim.api.nvim_set_keymap("x", "au", '<cmd>lua require"treesitter-unit".select(true)<CR>', silent)
  vim.api.nvim_set_keymap("o", "iu", '<cmd><c-u>lua require"treesitter-unit".select()<CR>', silent)
  vim.api.nvim_set_keymap("o", "au", '<cmd><c-u>lua require"treesitter-unit".select(true)<CR>', silent)
end

M.tmux = function()
  vim.api.nvim_set_keymap("n", "<C-k>", "<cmd>lua require('tmux').move_up()<CR>", silent)
  vim.api.nvim_set_keymap("n", "<C-j>", "<cmd>lua require('tmux').move_down()<CR>", silent)
  vim.api.nvim_set_keymap("n", "<C-h>", "<cmd>lua require('tmux').move_left()<CR>", silent)
  vim.api.nvim_set_keymap("n", "<C-l>", "<cmd>lua require('tmux').move_right()<CR>", silent)
end

M.vim_test = function()
  vim.api.nvim_set_keymap("n", "<Leader>t", "<cmd>TestNearest<CR>", silent)
  vim.api.nvim_set_keymap("n", "<LocalLeader>ta", "<cmd>TestAll<CR>", silent)
  vim.api.nvim_set_keymap("n", "<LocalLeader>tl", "<cmd>TestLast<CR>", silent)
  vim.api.nvim_set_keymap("n", "<LocalLeader>tf", "<cmd>TestFile<CR>", silent)
  vim.api.nvim_set_keymap("n", "<LocalLeader>ts", "<cmd>TestSuite<CR>", silent)
  vim.api.nvim_set_keymap("n", "<LocalLeader>tn", "<cmd>TestNearest<CR>", silent)
end

M.undotree = function()
  vim.api.nvim_set_keymap("n", "<LocalLeader>u", "<cmd>UndotreeToggle<CR>", silent)
end

M.visual_multi = function()
  vim.g.VM_maps = {
    ["Find Under"] = "<C-e>",
    ["Find Subword Under"] = "<C-e>",
    ["Select Cursor Down"] = "\\j",
    ["Select Cursor Up"] = "\\k",
  }
end

M.yabs = function()
  vim.api.nvim_set_keymap("n", "<LocalLeader>d", "<cmd>lua require('yabs'):run_default_task()<CR>", silent)
end
---------------------------------------------------------------------------- }}}
return M
