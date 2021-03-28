-------------------------------NEOVIM SETTINGS------------------------------ {{{
b.autoindent = true
b.expandtab = true -- Use spaces instead of tabs
b.shiftwidth = 4 -- Size of an indent
b.smartindent = true -- Insert indents automatically
b.softtabstop = 4-- Number of spaces tabs count for
b.tabstop = 4 -- Number of spaces tabs count for

o.backspace = [[indent,eol,start]]
o.clipboard = [[unnamed,unnamedplus]] -- Use the system clipboard
o.completeopt = [[menuone,noselect]] -- Completion options for code completion
o.encoding = 'UTF-8' -- Set the encoding type
o.hidden = true -- Enable modified buffers in background
o.history = 1000 -- Remember more stuff
o.hlsearch = true -- Highlight found searches
o.ignorecase = true -- Ignore case
o.incsearch = true -- Shows the match while typing
o.joinspaces = false -- No double spaces with join after a dot
o.scrolloff = 5 -- Set the cursor 5 lines down instead of directly at the top of the file
o.sidescrolloff = 8 -- Columns of context
o.shiftround = true -- Round indent
o.shortmess = o.shortmess .. "c" -- Do not show completion messages in command line e.g. "Pattern not found"
o.shortmess = o.shortmess .. "F" -- Do not show file info when editing a file, in the command line
o.shortmess = o.shortmess .. "W" -- Do not show "written" in command line when writing
o.shortmess = o.shortmess .. "I" -- Do not show intro message when starting Vim
o.showcmd = true -- Show me what I'm typing
o.showmatch = true -- Do not show matching brackets by flickering
o.showmode = false -- Do not show the mode
o.smartcase = true -- Don't ignore case with capitals
o.splitbelow = true -- Put new windows below current
o.splitright = true -- Put new windows right of current
o.termguicolors = true -- True color support
o.wildmode = 'list:longest' -- Command-line completion mode
o.wildignore = [[*/.git/*,*/node_modules/*]] -- Ignore these files/folders

w.colorcolumn = '80' -- Make a ruler at 80px
w.list = true -- Show some invisible characters like tabs etc
w.number = true -- Show line number
w.numberwidth = 2 -- Make the line number column thinner
w.signcolumn = 'yes' -- Show information next to the line numbers
w.wrap = false -- Disable line wrap

o.foldenable = true -- Enable folding
o.foldlevel = 0 -- Fold by default
o.modelines = 1 -- Only use folding settings for this file
o.foldmethod = 'marker' -- Fold based on markers as opposed to indentation

g.neoterm_autoinsert = 0 -- Do not start terminal in insert mode
g.neoterm_autoscroll = 1 -- Autoscroll the terminal

if fn.isdirectory(fn.stdpath('config')..'/.backup') == 0 then
 cmd('call mkdir(stdpath(\'config\').\'/.backup\'), \'p\', 0700')
end
if fn.isdirectory(fn.stdpath('config')..'/.undo') == 0 then
 cmd('call mkdir(stdpath(\'config\').\'/.undo\'), \'p\', 0700')
end
if fn.isdirectory(fn.stdpath('config')..'/.swap') == 0 then
 cmd('call mkdir(stdpath(\'config\').\'/.swap\'), \'p\', 0700')
end
if fn.isdirectory(fn.stdpath('config')..'/.session') == 0 then
 cmd('call mkdir(stdpath(\'config\').\'/.session\'), \'p\', 0700')
end

o.backupdir = fn.stdpath('config')..'/.backup' -- Use backup files
o.directory = fn.stdpath('config')..'/.swap' -- Use Swap files
o.undofile = true -- Maintain undo history between sessions
o.undolevels = 1000 -- Ensure we can undo...a lot
o.undodir = fn.stdpath('config')..'/.undo' -- Set the undo directory
sessiondir = fn.stdpath('config')..'/.session' -- Set the session directory
---------------------------------------------------------------------------- }}}
----------------------------------MAPPINGS---------------------------------- {{{
utils.map('n', ';', ':') -- Faster way to enter a command
utils.map('i', 'jk', '<esc>', {silent = true}) -- Make escape easier to reach
-- utils.map('n', '<Leader>td', ' <cmd>e todo.txt<CR>', {silent = true})
utils.map('n', '<Leader>w', ' <cmd>w<CR>', {silent = true})

-- Working with init.lua
utils.map('n', '<Leader>v', '<cmd>e $MYVIMRC | cd %:p:h<CR>', {silent = true})
utils.map('n', '<Leader>s', '<cmd>w<CR><cmd>luafile $MYVIMRC<CR>', {silent = true})
utils.map('n', '<Leader>p', '<cmd>e $PLUGINRC<CR>', {silent = true})

--noremap <silent><c-C>  <cmd>call CloseBufferAndPreviewWindows()<CR>

-- Finding and highlighting values
-- utils.map('n', '<C-f>', ' :/')
utils.map('n', '<Leader>f', ' :%s/{search}/{replace}/g')
utils.map('v', '<Leader>f', ' :s/{search}/{replace}/g')
utils.map('n', '<Leader>h', '<cmd>nohlsearch<CR>', {silent = true})

-- Movement
utils.map('n', 'j', 'gj', {silent = true})
utils.map('n', 'k', 'gk', {silent = true})
utils.map('n', 'B', '^', {silent = true})
utils.map('n', 'E', '$', {silent = true})

-- Move lines of code up or down
utils.map('n', '∆', ' <cmd>m .+1<CR>==', {silent = true})
utils.map('n', '˚', ' <cmd>m .-2<CR>==', {silent = true})
utils.map('i', '∆', '<Esc> <cmd>m .+1<CR>==gi', {silent = true})
utils.map('i', '˚', ' <cmd><Esc>m .-2<CR>==gi', {silent = true})
utils.map('v', '∆', ' <cmd>m \'>+1<CR>gv=gv', {silent = true})
utils.map('v', '˚', ' <cmd>m \'<-2<CR>gv=gv', {silent = true})

utils.map('v', '<', '<gv') -- Reselect the visual block after indent
utils.map('v', '>', '>gv') -- Reselect the visual block after outdent

-- Splits
utils.map('n', 'sv', '<cmd>vsplit<CR>') -- Create vertical split
utils.map('n', 'sh', '<cmd>split<CR>') -- Create horizontal split
utils.map('n', 'sc', '<C-w>q') -- Close the current split
utils.map('n', 'so', '<C-w>o') -- Close all splits but the current one
utils.map('n', 'se', '<C-w>=') -- Resize all spltis evenly

utils.map('n', '<C-h>', '<C-w>h') -- Move between splits
utils.map('n', '<C-j>', '<C-w>j') -- Move between splits
utils.map('n', '<C-k>', '<C-w>k') -- Move between splits
utils.map('n', '<C-l>', '<C-w>l') -- Move between splits

-- utils.map('n', '<Leader>c', ' <cmd>only \\|  <cmd>tabclose<CR>') -- Close all splits and tabs

-- Tabs
utils.map('n', '<Leader>tc', '<cmd>tabclose<CR>')
utils.map('n', '<Leader>to', '<cmd>tabonly<CR>')
utils.map('n', '<Leader>te', '<cmd>tabe %<CR>')
-- Next tab is gt
-- Previous tab is gT

-- Terminal mode
utils.map('t', '<esc>', '<C-\\><C-n>') -- Escape in the terminal closes it
utils.map('t', ':q!', '<C-\\><C-n>:q!<CR>') -- In the terminal :q quits it

-- Python
if fn.filereadable('~/.asdf/shims/python2') then
 g.python_host_prog = '~/.asdf/shims/python2'
end
if fn.filereadable('~/.asdf/shims/python3') then
 g.python3_host_prog = '~/.asdf/shims/python3'
end
-- Execute a Python file
utils.map('n', '<Leader>r', ' <cmd>w!<CR> <cmd>FloatermNew \'1T python\'.shellescape(\'@%\', 1)<CR>')
---------------------------------------------------------------------------- }}}
----------------------------------COMMANDS---------------------------------- {{{
-- Indentation based on filetypes
cmd 'autocmd Filetype lua setlocal ts=2 sw=2 expandtab'
cmd 'autocmd Filetype javascript setlocal ts=4 sw=4 sts=0 expandtab'
---------------------------------------------------------------------------- }}}