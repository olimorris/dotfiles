-- Documentation: https://neovim.io/doc/user/options.html
------------------------------GLOBAL VARIABLES------------------------------ {{{
Homedir = os.getenv("HOME")
Sessiondir = vim.fn.stdpath("data") .. "/sessions"
--------------------------------------------------------------------------- }}}
-------------------------------GLOBAL OPTIONS------------------------------- {{{
vim.g.neoterm_autoinsert = 0 -- Do not start terminal in insert mode
vim.g.neoterm_autoscroll = 1 -- Autoscroll the terminal
vim.g.loaded_perl_provider = 0 -- Do not load Perl
if vim.fn.filereadable(os.getenv("HOME_DIR") .. ".asdf/shims/python2") then
  vim.g.python_host_prog = os.getenv("HOME_DIR") .. ".asdf/shims/python2"
end
if vim.fn.filereadable(os.getenv("HOME_DIR") .. ".asdf/shims/python") then
  vim.g.python3_host_prog = os.getenv("HOME_DIR") .. ".asdf/shims/python"
end

--------------------------------------------------------------------------- }}}
-------------------------------BUFFER OPTIONS------------------------------- {{{
vim.bo.autoindent = true
vim.bo.expandtab = true -- Use spaces instead of tabs
vim.bo.shiftwidth = 4 -- Size of an indent
vim.bo.smartindent = true -- Insert indents automatically
vim.bo.softtabstop = 4 -- Number of spaces tabs count for
vim.bo.tabstop = 4 -- Number of spaces in a tab
-- vim.bo.wrapmargin = 1
--------------------------------------------------------------------------- }}}
---------------------------------VIM OPTIONS-------------------------------- {{{
vim.o.background = "dark"
vim.opt.cmdheight = 0 -- Hide the command bar
vim.opt.clipboard = { "unnamedplus" } -- Use the system clipboard
vim.opt.completeopt = { "menuone", "noselect" } -- Completion opions for code completion
vim.opt.cursorlineopt = "screenline,number" -- Highlight the screen line of the cursor with CursorLine and the line number with CursorLineNr
vim.opt.emoji = false -- Turn off emojis
vim.opt.fillchars = {
  horiz = "━",
  horizup = "┻",
  horizdown = "┳",
  vert = "┃",
  vertleft = "┫",
  vertright = "┣",
  verthoriz = "╋",
}
vim.opt.foldenable = true -- Enable folding
vim.opt.foldlevel = 0 -- Fold by default
vim.opt.foldmethod = "marker" -- Fold based on markers as opposed to indentation
vim.opt.ignorecase = true -- Ignore case
vim.opt.laststatus = 3 -- Use global statusline
vim.opt.modelines = 1 -- Only use folding settings for this file
vim.opt.mouse = "a" -- Use the mouse in all modes
vim.o.sessionoptions = "buffers,curdir,folds,globals,tabpages,winpos,winsize" -- Session options to store in the session
vim.opt.scrolloff = 5 -- Set the cursor 5 lines down instead of directly at the top of the file
--[[
	NOTE: don't store marks as they are currently broken in Neovim!
	@credit: wincent
]]
vim.opt.shada = "!,'0,f0,<50,s10,h"
vim.opt.shell = "/opt/homebrew/bin/fish"
vim.opt.shiftround = true -- Round indent
vim.opt.shortmess = {
  A = true, -- ignore annoying swap file messages
  c = true, -- Do not show completion messages in command line
  F = true, -- Do not show file info when editing a file, in the command line
  I = true, -- Do not show the intro message
  W = true, -- Do not show "written" in command line when writing
}
-- vim.opt.showcmd = true -- Do not show me what I'm typing
vim.opt.showmatch = true -- Show matching brackets by flickering
vim.opt.showmode = false -- Do not show the mode
vim.opt.sidescrolloff = 8 -- The minimal number of columns to keep to the left and to the right of the cursor if 'nowrap' is set
vim.opt.smartcase = true -- Don't ignore case with capitals
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitright = true -- Put new windows right of current
vim.o.termguicolors = true -- True color support
vim.opt.textwidth = 120 -- Total allowed width on the screen
vim.opt.timeout = true -- This option and 'timeoutlen' determine the behavior when part of a mapped key sequence has been received. This is on by default but being explicit!
vim.opt.timeoutlen = 500 -- Time in milliseconds to wait for a mapped sequence to complete.
vim.opt.ttimeoutlen = 10 -- Time in milliseconds to wait for a key code sequence to complete
vim.opt.updatetime = 100 -- If in this many milliseconds nothing is typed, the swap file will be written to disk. Also used for CursorHold autocommand and set to 100 as per https://github.com/antoinemadec/FixCursorHold.nvim
vim.opt.wildmode = "list:longest" -- Command-line completion mode
vim.opt.wildignore = { "*/.git/*", "*/node_modules/*" } -- Ignore these files/folders

-- Create folders for our backups, undos, swaps and sessions if they don't exist
vim.cmd("silent call mkdir(stdpath('data').'/backups', 'p', '0700')")
vim.cmd("silent call mkdir(stdpath('data').'/undos', 'p', '0700')")
vim.cmd("silent call mkdir(stdpath('data').'/swaps', 'p', '0700')")
vim.cmd("silent call mkdir(stdpath('data').'/sessions', 'p', '0700')")

vim.opt.backupdir = vim.fn.stdpath("data") .. "/backups" -- Use backup files
vim.opt.directory = vim.fn.stdpath("data") .. "/swaps" -- Use Swap files
vim.opt.undofile = true -- Maintain undo history between sessions
vim.opt.undolevels = 1000 -- Ensure we can undo a lot!
vim.opt.undodir = vim.fn.stdpath("data") .. "/undos" -- Set the undo directory
--------------------------------------------------------------------------- }}}
-------------------------------WINDOW OPTIONS------------------------------- {{{
vim.wo.colorcolumn = "80,120" -- Make a ruler at 80px and 120px
vim.wo.list = true -- Show some invisible characters like tabs etc
vim.wo.numberwidth = 2 -- Make the line number column thinner
---Note: Setting number and relative number gives you hybrid mode
---https://jeffkreeftmeijer.com/vim-number/
vim.wo.number = true -- Set the absolute number
vim.wo.relativenumber = true -- Set the relative number
vim.wo.signcolumn = "yes" -- Show information next to the line numbers
vim.wo.wrap = false -- Do not display text over multiple lines
---------------------------------------------------------------------------- }}}
--------------------------DISABLE BUILT IN PLUGINS-------------------------- {{{
local disabled_plugins = {
  "2html_plugin",
  "getscript",
  "getscriptPlugin",
  "gzip",
  "logipat",
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers",
  "matchit",
  "tar",
  "tarPlugin",
  "rrhelper",
  "spellfile_plugin",
  "vimball",
  "vimballPlugin",
  "zip",
  "zipPlugin",
}
for _, plugin in pairs(disabled_plugins) do
  vim.g["loaded_" .. plugin] = 1
end
---------------------------------------------------------------------------- }}}
