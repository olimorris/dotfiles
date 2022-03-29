" Initial Settings {{{

set nocompatible
set nobackup
set history=1000
set undolevels=1000
set wildignore+=*.swp,*.bak,*.pyc,*.class,*/node_modules/*
set undofile                                                " Maintain undo history between sessions
set undodir=$HOME/.vim/undo                                 " Store undo history
set directory=$HOME/.vim/swp/                               " Store swap files in the vim directory

filetype plugin indent on                                   " Allow custom filetypes

" }}}
" Load Plugins {{{
if filereadable(expand("~/.vimrc.plugins"))
    source ~/.vimrc.plugins
endif
" }}}
" Vimrc {{{
" Theming {{{

if !has('gui_running')
    set t_Co=256                                " Set the maximum number of colors in vim
endif
syntax on                                       " Enable syntax processing

set background=dark                             " The background to be used in Vim
colorscheme onedark

set linespace=2                                 " Set the line height
set encoding=utf8                               " Set encoding type
let g:enable_bold_font = 1                      " Enable bolding of fonts
set guifont=Operator_mono_for_powerline_medium:h16            " Set the font and font size

set guioptions-=T                               " Removes top toolbar
set guioptions-=r                               " Removes right hand scroll bar
set guioptions-=L                               " Removes left hand scroll bar
set guioptions-=m                               " Removes menu bar

" Ensure that splits don't have discoloured borders
hi vertsplit guifg=fg guibg=bg

" Set highlights for Operator Mono font
function! HighlightSyntax()
    hi Type gui=italic cterm=italic
    hi htmlArg gui=italic cterm=italic
    hi Comment gui=italic cterm=italic
    hi phpKeyword gui=italic cterm=italic
endfunction

call HighlightSyntax()
" }}}
" Spaces & Tabs {{{

set tabstop=4                               " A tab is four spaces
set softtabstop=4                           " When hitting <BS>, pretend like a tab is removed, even if spaces
set shiftwidth=4                            " Number of spaces to use for autoindenting
set expandtab                               " Tabs are spaces
set shiftround                              " Use multiple of shiftwidth when indenting with '<' and '>'

" Python PEP8 settings
"au BufNewFile,BufRead *.py
    "\ set tabstop=4
    "\ set softtabstop=4
    "\ set shiftwidth=4
    "\ set textwidth=79
    "\ set expandtab
    "\ set autoindent
    "\ set fileformat=unix

" Stop Vim from wrapping text
set nowrap
set textwidth=0
set wrapmargin=0

" }}}
" UI Config {{{

set ruler                                   " Enable the ruler
set colorcolumn=80,120                      " Make a ruler at 80px and 120px

set laststatus=2                            " Show the status bar
set noshowmode                              " Never show which mode we're working in
set number                                  " Show line numbers
set showcmd                                 " Show the command bar

set hidden                                  " Switch between buffers without saving
set ignorecase                              " Ignore case when searching
set smartcase                               " Ignore case if search pattern is all lowercase,
set visualbell                              " Don't beep
set noerrorbells                            " Don't beep
set mouse=a                                 " Enable mouse support
set smartindent                             " Use Vim's in built indenting capabilities
set autoindent                              " Always set autoindenting on
set copyindent                              " Copy the previous indentation on autoindenting
set lazyredraw                              " Only redraw when we need to
set wildmenu                                " Visual autocomplete for command menu

set backspace=indent,eol,start              " Allow backspacing over everything in insert mode
set timeout timeoutlen=200 ttimeoutlen=100  " The time Vim waits to write the swapfile to disk

set completeopt-=preview                    " Prevent the scratch preview window from appearing

let g:netrw_liststyle=3                     " Set Explorer to be NerdTree like
let g:netrw_browse_split=0                  " Open a file from netrw in the same split

" Change the cursor on insert mode when using Tmux
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7"
  let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

" }}}
" Searching {{{

set incsearch                               " Search as characters are entered
set hlsearch                                " Highlight matches
set smartcase                               " Ignore the case unless a capital is entered

" Remove search results
command! H let @/=""
highlight Search cterm=underline

" }}}
" Folding {{{

set foldenable                              " Enable folding
"set foldlevelstart=10                       " Open most folds by default
set foldnestmax=10                          " 10 nested fold max
set foldmethod=marker                       " Fold based on markers as opposed to indentation
set foldlevel=0                             " By default fold everything
set modelines=1                             " Only use folding settings for this file

" Set the fold background
"hi Folded guibg=#212D32

" }}}
" Mappings {{{
" Leader Key - Must come first {{{

" Set to space
let mapleader=" "

" }}}
" General Vim {{{

" Easy escape
inoremap jj <ESC>
imap jk <esc>
vmap jk <esc>

" Toggle gundo
nnoremap <c-u> :GundoToggle<CR>

" Fast saves - Ignores any prompts
nmap <leader>w :w!<cr>
imap <leader>w <esc>:w!<cr>a

" Add simple highlight removal
nmap <leader><space> :nohlsearch<cr>

" Edit vimrc/zshrc and load vimrc bindings
nnoremap <leader>ev :e ~/.vimrc<CR>
nnoremap <leader>ez :e ~/.zshrc<CR>
nnoremap <leader>sv :source ~/.vimrc<CR>
nnoremap <leader>ep :e ~/.vimrc.plugins<CR>
nnoremap <leader>ip :PlugInstall<CR>
nnoremap <leader>up :PlugUpdate<CR>

" Save session
nnoremap <leader>s :mksession<CR>

" Toggle relative numbers
"nnoremap <silent><c-R> :set relativenumber!<cr>

" Ctrl F - Find
nmap <C-f> :/
imap <C-f> :/
vmap <C-f> :/

" Ctrl Capital F - Search and Replace
nmap <leader>f :%s/{search}/{replace}/g
imap <leader>f :%s/{search}/{replace}/g
vmap <leader>f :%s/{search}/{replace}/g

" Insert new line without entering insert mode
nmap <C-CR> O<esc>
nmap <CR> o<esc>
" }}}
" Movement {{{

" move vertically by visual line
nnoremap j gj
nnoremap k gk

" move to beginning/end of line
nnoremap B ^
nnoremap E $

" $/^ doesn't do anything
nnoremap $ <nop>
nnoremap ^ <nop>

" highlight last inserted text
nnoremap gV `[v`]

" Move lines of code up or down
nnoremap ∆ :m .+1<CR>==
nnoremap ˚ :m .-2<CR>==
inoremap ∆ <Esc>:m .+1<CR>==gi
inoremap ˚ <Esc>:m .-2<CR>==gi
vnoremap ∆ :m '>+1<CR>gv=gv
vnoremap ˚ :m '<-2<CR>gv=gv

map M-j :m .+1<CR>==

" }}}
" Splits {{{

" Use CTRL and HJKL to move between splits if Tmux isn't open
" Within Tmux, we use these shortcuts to move between splits
if ! exists('$TMUX')
    nmap <C-h> <C-w>h
    nmap <C-j> <C-w>j
    nmap <C-k> <C-w>k
    nmap <C-l> <C-w>l
endif

" Resize splits
nmap 25 :vertical resize 40<cr>
nmap 50 <c-w>=
nmap 75 :vertical resize 120<cr>

" Create split below
nmap bs :rightbelow sp<cr>

" Create new splits
nmap vs :vsplit<cr>
nmap hs :split<cr>

" Close the split
nmap cs <c-w>q

" Close all splits except for the current one
map <leader>c :only<cr>
" }}}
" Buffers {{{

" Cycle through open buffers
if has('gui_running')
  nnoremap <C-Tab> :bnext<CR>
  nnoremap <C-S-Tab> :bprevious<CR>
else
  nnoremap <s-L> :bnext<CR>
  nnoremap <s-H> :bprevious<CR>
endif

" Load the current buffer in Chrome
" nmap ,c :!open -a Google\ Chrome<cr>

" Close the file from the buffer but do not close the split
" Uses the awesome Bufkill plugin
map <C-c> :BD<cr>

" Delete all buffers
nmap <silent> ,da :exec "1," . bufnr(' $') . "bd"<cr>

" }}}
" Directories {{{

" Go straight to the code base
nnoremap ,om :cd ~/Code/PHP/OliMorrisBlog<CR>
nnoremap ,sh :cd ~/Code/PHP/Shorty<CR>

" }}}
" PHP {{{

" Sort PHP use statements
" http://stackoverflow.com/questions/11531073/how-do-you-sort-a-range-of-lines-by-length
vmap <leader>su ! awk '{ print length(), $0 \| "sort -n \| cut -d\\  -f2-" }'<cr>

" Add a semicolon to the end of a line and move down.
nmap <leader>; A;<esc>j
imap <leader>; <esc>A;<esc>j

" }}}
" Laravel {{{

" To files
nmap <leader>lw :e routes/web.php<cr>
nmap <leader>lca :e app/config/app.php<cr>81Gf(%O
nmap <leader>lcd :e app/config/database.php<cr>
nmap <leader>lc :e composer.json<cr>

" To views
nmap <leader>lv :e /resources/views/<cr>

" }}}
" Ruby {{{

" Run Ruby from the command line
nmap <leader>ru :!ruby %<cr>
imap <leader>ru :!ruby %<cr>

" }}}
" Misc {{{

" Edit ToDos
nmap ,todo :e todo.md<cr>

" Remove whitespace
nmap <leader>rw :%s/\s\+$//e <bar> nohlsearch<cr>

" Create/edit file in the current directory
nmap :ed :edit %:p:h/

" Spell checking
nmap <leader>sp :set spell<cr>
nmap <leader>ns :set nospell<cr>
nmap <leader>su z=

" }}}
" }}}
" Plugins {{{
" Ack {{{

" Use The Silver Searcher
if executable('ag')
    let g:ackprg = 'ag --vimgrep'
endif

" Close the window on opening a file
let g:ack_autoclose = 1

" }}}
" Ale {{{

" Set the warning signs
let g:ale_sign_warning = '▲'
let g:ale_sign_error = '✗'

" Do not lint Vim files
let g:ale_linters = {
      \     'stylus': [],
      \ }

" }}}
" Autoformat {{{

noremap <leader>f :Autoformat<cr>

" Turn this to 1 if the plugin isn't working
let g:autoformat_verbosemode=0

" }}}
" Bufferline {{{

" Do not show buffer numbers
let g:bufferline_show_bufnr = 0

" }}}
" CTags {{{

" Set the tags file for Ctags
set tags=tags

" Tagbar options
let g:tagbar_usearrows = 1

" }}}
" Emmet {{{

" Enable in all modes
let g:user_emmet_mode='a'

" Ctrl+y to trigger Emmet in any mode
nmap <C-y> <plug>(emmet-expand-abbr)
imap <C-y> <plug>(emmet-expand-abbr)
vmap <C-y> <plug>(emmet-expand-abbr)

" }}}
" FZF {{{

set rtp+=/opt/homebrew/bin/fzf

nmap ; :Buffers<CR>
nmap <C-p> :Files<CR>
nmap <C-e> :Tags<CR>

" }}}
" Gv {{{

" Map the Commit Browser as vc as in View Commits
nnoremap <leader>vc :GV<cr>

" When in the Commit Browser:
" q     - quits it
" gb    - opens the commit in GitHub

" }}}
" Gutentags {{{

let g:gutentags_enabled = 1

" Make new tags using Gutentags
map <leader>mt :GutentagsUpdate<CR>

" }}}
" HTML Auto Close {{{

let g:closetag_filenames = "*.html,*.xhtml,*.phtml,*.html.erb,*.blade.php"

" }}}
" Indentation {{{

  " Disable by default
  let g:indentLine_enabled = 0

  " Set the default indentation character
  let g:indentLine_char = '⎸'

" }}}
" Lightline {{{
    " Config {{{
    let g:lightline = {
          \ 'colorscheme': 'wombat',
          \ 'active': {
          \   'left': [
          \       ['mode', 'paste'],
          \       ['gitbranch', 'filename', 'modified']
          \   ],
          \   'right': [
          \       ['project_name'],
          \       ['percent'],
          \       ['vim_obsession', 'filetype', 'lineinfo'],
          \       ['read_only', 'linter_warnings', 'linter_errors']
          \   ]
          \ },
          \ 'component_expand': {
          \   'linter_warnings': 'LightlineLinterWarnings',
          \   'linter_errors': 'LightlineLinterErrors'
          \ },
          \ 'component_type': {
          \   'linter_warnings': 'warning',
          \   'linter_errors': 'error'
          \ },
          \ 'component_function': {
          \   'gitbranch': 'GitBranch',
          \   'project_name': 'ProjectName',
          \   'read_only': 'ReadOnly',
          \   'vim_obsession': 'ObsessionStatus'
          \ },
      \ }
    " }}}
    " Custom Functions {{{
    function! LightlineLinterWarnings() abort
        let l:counts = ale#statusline#Count(bufnr(''))
        let l:all_errors = l:counts.error + l:counts.style_error
        let l:all_non_errors = l:counts.total - l:all_errors
        return l:counts.total == 0 ? '' : printf('%d ◆', all_non_errors)
    endfunction

    function! LightlineLinterErrors() abort
        let l:counts = ale#statusline#Count(bufnr(''))
        let l:all_errors = l:counts.error + l:counts.style_error
        let l:all_non_errors = l:counts.total - l:all_errors
        return l:counts.total == 0 ? '' : printf('%d ✗', all_errors)
    endfunction

    function! LightlineLinterOK() abort
        let l:counts = ale#statusline#Count(bufnr(''))
        let l:all_errors = l:counts.error + l:counts.style_error
        let l:all_non_errors = l:counts.total - l:all_errors
        return l:counts.total == 0 ? '✓ ' : ''
    endfunction

    autocmd User ALELint call s:MaybeUpdateLightline()

    " Update and show lightline but only if it's visible (e.g., not in Goyo)
    function! s:MaybeUpdateLightline()
        if exists('#lightline')
            call lightline#update()
        end
    endfunction

    function! GitBranch()
        let git = fugitive#head()

        if git != ''
            return ' ' .fugitive#head()
        else
            return ''
        endif
    endfunction

    function! ProjectName()
        return GetProjectDir()
    endfunction

    function! ReadOnly()
        if &readonly || !&modifiable
            return ''
        else
            return ''
        endif
    endfunction
    " }}}
" }}}
" MatchTagAlways {{{
    nnoremap <leader>% :MtaJumpToOtherTag<cr>
" }}}
" Multiple Cursors {{{

" Multiple cursors clashes with Neocomplete. This fix sorts it.
" https://github.com/terryma/vim-multiple-cursors#quick-start

" Called once right before you start selecting multiple cursors
function! Multiple_cursors_before()
    if exists(':NeoCompleteLock')==2
        exe 'NeoCompleteLock'
    endif
endfunction

" Called once only when the multiple selection is canceled (default <Esc>)
function! Multiple_cursors_after()
    if exists(':NeoCompleteUnlock')==2
        exe 'NeoCompleteUnlock'
    endif
endfunction

" }}}
" NerdTree {{{

nmap <C-b> :NERDTreeToggle<CR>
nmap <C-z> :NERDTreeFind<CR>

" Don't let Nerdtree Hijack Vinegar.vim
let NERDTreeHijackNetrw = 0

" Enable space bar to open folders in NERDTree
let NERDTreeMapActivateNode = '<space>'

" }}}
" PHP Namespace {{{

inoremap <Leader>u <C-O>:call PhpInsertUse()<CR>
noremap <Leader>u :call PhpInsertUse()<CR>

"}}}
" PHP-CS-Fixer {{{
let g:php_cs_fixer_path = "~/.composer/vendor/bin/php-cs-fixer"
let g:php_cs_fixer_php_path = "/usr/local/bin/php"
let g:php_cs_fixer_rules = "@PSR2"
" }}}
" Plug {{{

let g:plug_window = 'enew'

" }}}
" Projectroot {{{
function! SetCurrentDirectory()
    exec "cd " . ProjectRootGuess()
    exec "pwd"
endfunction
nnoremap <leader>cd :call SetCurrentDirectory()<cr>
" }}}
" Rainbow Parenthesis {{{

let g:rainbow_active = 0                    " Run :RainbowToggle to load
abbrev rain !RainbowToggle<CR>

" }}}
" Startify {{{
let g:startify_change_to_dir = 0
let g:startify_list_order = ['sessions', 'files', 'dir', 'bookmarks',
            \ 'commands']

" Open Startify
nmap <leader>§ :Startify<cr>

" Save the session
nmap <leader>§s :SSave<cr>

" Load a saved session
nmap <leader>§l :SLoad<cr>

" Delete a saved session
nmap <leader>§d :SDelete<cr>

" Close the current session
nmap <leader>§c :SClose<cr>
" }}}
" Tagbar {{{

" Toggle open/close of Tagbar
map <c-t> :TagbarToggle<CR>

" Automatically close Tagbar when you've selected a file
let g:tagbar_autoclose = 1

" Focus the cursor in Tagbar when opened
let g:tagbar_autofocus = 1

" Sort tags by their order in the buffer
let g:tagbar_sort = 0

" Remove spacing between the tag types
let g:tagbar_compact = 1

" Open Tagbar on the right hand side
let g:tagbar_left = 0

" Open Tagbar wider than the default 40px
let g:tagbar_width = 30

" Indent tags by 1 instead of the default 2
let g:tagbar_indent = 1

" Fold tag types which have more than 10 elements (i.e. variables)
let g:tagbar_foldlevel = 8

" Set the icons in Tagbar
let g:tagbar_iconchars = ['▸', '▾']

" }}}
" UltiSnips {{{

" Set the directories to where we store our snippets
let g:UltiSnipsSnippetDirectories = ["custom_snippets"]

" Mappings
let g:UltiSnipsExpandTrigger = "<c-e>"
let g:UltiSnipsJumpForwardTrigger = "<c-l>"
let g:UltiSnipsJumpBackwardTrigger = "<c-z>"        " Ctrl+h would be ideal but it is reserved for backspacing

" }}}
" Vim After Object {{{

autocmd VimEnter * call after_object#enable('=', ':', ' ', ',', ';')

" }}}
" Vim JSON {{{

" Do not conceal bracets or quotation marks
let g:vim_json_syntax_conceal = 0

" }}}
" Vim Over {{{

nmap <leader>v :OverCommandLine<cr>%s/

" }}}
" Vim Test {{{
" PHP {{{

" Point to PHPUnit
let test#php#phpunit#executable = 'vendor/bin/phpunit'

" Do not show colors in MacVim
"let test#php#phpunit#options = '--colors=always'

" Custom strategy for running in Iterm
function! CustomIterm(cmd)
    silent echo ClearTerminal()
    silent echo SendToTerminal('(cd '. ProjectRootGuess() . ' && ' . a:cmd . ')')
endfunction
let g:test#custom_strategies = {'CustomIterm': function('CustomIterm')}

" Set the test strategy
if has('gui_running')
    let test#strategy = "CustomIterm"
else
    let test#strategy = 'vimux'
endif
" }}}
" Mappings {{{
nmap <silent> <leader>tl :w!<CR>:TestLast<CR>
nmap <silent> <leader>tf :w!<CR>:TestFile<CR>
nmap <silent> <leader>tt :w!<CR>:TestSuite<CR>
nmap <silent> <leader>t :w!<CR>:TestNearest<CR>

imap <silent> <leader>tl <c-o>:w!<CR><c-o>:TestLast<CR>
imap <silent> <leader>tf <c-o>:w!<CR><c-o>:TestFile<CR>
imap <silent> <leader>tt <c-o>:w!<CR><c-o>:TestSuite<CR>
imap <silent> <leader>t <c-o>:w!<CR><c-o>:TestNearest<CR>
" }}}
" }}}
" Vim Vue {{{

" Sometimes Vue syntax highlighting doesn't work
autocmd FileType vue syntax sync fromstart

" }}}
" Vimux {{{

" Create new panes vertically (yes that's a h!)
let g:VimuxOrientation = "h"

" Take up more screen space
let g:VimuxHeight = "50"

" }}}
" }}}
" Custom Functions {{{
" Directory Detection {{{

" Vim makes it difficult to get the exact filename of the current file.
" This function uses trickery to obtain that by splitting a string
" based on '/'s.
function! GetFilename(Filename)
    let s:correct_filename = a:Filename
    let s:correct_filename = split(s:correct_filename, "/")
    return s:correct_filename[len(s:correct_filename) - 1]
endfunction

" Work out the current directory of the site we are in.
" Assumes the site is one folder beneath the directory parameter.
function! GetProjectDir()

    try
        let dir = ProjectRootGuess()
        let s:full_path = split(fnameescape(dir), "/")
        let s:site_path = s:full_path[len(s:full_path) - 1]
    catch
        " On any error just return the app name - for instance when we
        " are editing our Vimrc file
        let s:site_path = "Vim"
    endtry

    return s:site_path
endfunction

" }}}
" Files - Rename {{{
" Functions {{{
function! Rename(name, bang)
    let l:curfile = expand("%:p")
    let l:curpath = expand("%:h") . "/"
    let v:errmsg = ""
    silent! exe "saveas" . a:bang . " " . fnameescape(l:curpath . a:name)
    if v:errmsg =~# '^$\|^E329'
        let l:oldfile = l:curfile
        let l:curfile = expand("%:p")
        if l:curfile !=# l:oldfile && filewritable(l:curfile)
            silent exe "bwipe! " . fnameescape(l:oldfile)
            if delete(l:oldfile)
                echoerr "Could not delete " . l:oldfile
            endif
        endif
    else
        echoerr v:errmsg
    endif
endfunction

function! RenameFileAndClass()
    let b:newname = input('Rename to: ', expand('%:t') . "\<left>\<left>\<left>\<left>")

    " Exit the function on escape
    if empty(b:newname)
        return
    endif

    " Get rid of the user input box
    redraw!

    if search('class ') > 0
        let b:name_without_extension = split(b:newname, '\.')
        call cursor (1,1)
        exe 'normal /class
wcw' . b:name_without_extension[0]
    endif

    exe Rename(b:newname, '')
endfunction
" }}}
" Mapping {{{
nnoremap <leader>re :call RenameFileAndClass()<cr>
" }}}
" }}}
" Files - Ag Searching {{{
function! Ag_smart_search()

    let l:searchFor = input("Search For: ")

    if l:searchFor == ""
        return
    endif

    let l:searchFilePrefix = input("File Prefix: ")
    let l:options = input("Pass Options: ")

    if l:searchFilePrefix != "" && l:searchFilePrefix != "*"
        let l:searchFilePrefix = "-G " . l:searchFilePrefix
    endif

    execute "Ack! " . l:options . " '" . l:searchFor . "' " . ProjectRootGuess() . " " . l:searchFilePrefix . " --ignore-dir={node_modules,vendor}"
endfunction

nnoremap <C-a> :call Ag_smart_search()<cr>

" }}}
" Files - Ag Search and Replace {{{
function! ProjectSearchAndReplace()
    let l:searchFor = input ("Search For: ")
    let l:replaceWith = input ("Replace With: ")

    if l:searchFor != "" && l:replaceWith != ""

        let l:excludeCurrentFile = input ("Exclude Current File? (Y/N): ", "Y")
        let l:options = input("Pass Options: ")

        if l:excludeCurrentFile == "Y" || l:excludeCurrentFile == "y"
            " The current file
            let l:ignoreFile = expand("%:t")
        endif

        let l:ack_command = "Ack! " . l:options . " '" . l:searchFor . "' " . ProjectRootGuess() . " --ignore-dir={node_modules,vendor}"

        if exists("l:ignoreFile")
            let l:ack_command = l:ack_command . " --ignore=" . l:ignoreFile
        endif

        execute l:ack_command
        execute "cdo s/" . l:searchFor . "/" . l:replaceWith . "/ge"
    endif
endfunction

abbr snr :call ProjectSearchAndReplace()

" Update all of the opened buffers, then close them, then select the buffer
" that we were making the changes in and then close the quickfix window.
function! SaveSearchAndReplace()
    execute "cdo | update"
    execute "cfdo bd"
    execute "bprev"
    execute "ccl"
endfunction

abbr ssr :call SaveSearchAndReplace()<cr>

" }}}
" Files - Toggle Maximum Display {{{
" Functions {{{
let g:hidden_all = 0
function! ToggleHiddenAll()
    if g:hidden_all  == 0
        let g:hidden_all = 1
        set noshowmode
        set noruler
        set noshowcmd
        set nonumber
        set norelativenumber
    else
        let g:hidden_all = 0
        set showmode
        set ruler
        set showcmd
        set number
    endif
endfunction
" }}}
" Mappings {{{
nnoremap <Leader>h :call ToggleHiddenAll()<CR>
" }}}
" }}}
" General - Edit Snippets {{{
" Functions {{{
function! SnippetLookup()
    let snippet = input('Snippets to Edit: ')
    execute ":edit ~/.vim/custom_snippets/" . snippet .".snippets"
endfunction
" }}}
" Mappings {{{
nmap <leader>es :call SnippetLookup()<cr>
"}}}
" }}}
" General - Append and Prepend Lines {{{
function! PrependAppendLines()
    let prepend = input('Prepend: ')
    let append = input ('Append: ')

    exec ':''<,''>s/\(\S\+\)/'. prepend . '\1' . append .'/'
endfunction

nmap <leader>2 :call PrependAppendLines()<cr>
" }}}
" Shell - Send Command to iTerm {{{
function! SendToTerminal(args)
    execute ":w"
    execute ":silent !run_iterm_from_macvim '" . a:args . "'"
endfunction

function! ClearTerminal()
    call SendToTerminal("clear")
endfunction
" }}}
" Stylus - Remove Semi-Colons and Parenthesis {{{

function! CleanUpStylus() range
    " Remove semicolons
    silent! execute '%s/;//'
    silent! execute '%s/{//'
    silent! execute '%s/}//'
endfunction

" }}}
" Auto Commands {{{

" Auto format JS and SCSS files
"autocmd BufWritePre *.js,*.scss,*.erb :Autoformat

" Ensure netrw disappears when you close it
autocmd FileType netrw setl bufhidden=wipe

" Remove unwanted whitespace
autocmd BufWritePre *.{php,js,scss,styl,html.erb,erb,rb} :%s/\s\+$//e

" Automatically source the Vimrc file and plugins file on save.
autocmd! BufWritePost $MYVIMRC source $MYVIMRC
autocmd! BufWritePost ~/.vimrc.plugins source ~/.vimrc.plugins

" Run python files with a shortcut
autocmd FileType python noremap <buffer> <leader>r :w<cr>:exec '! clear; python' shellescape(@%, 1)<cr>

" Set netrw to be hidden
autocmd FileType netrw setl bufhidden=wipe

"
" }}}
" Change Colour Scheme {{{
function! ChangeColorScheme() abort

    let color_schemes = {
        \       'schemes': [ 'onedark', 'materialbox' ],
        \       'background': [ 'dark', 'light' ],
        \       'lightline': ['wombat', 'solarized']
        \   }

    let max_schemes = len(color_schemes.schemes) - 1
    let current_scheme = index(color_schemes.schemes, g:colors_name)

    if max_schemes != (len(color_schemes.background) - 1)
        return
    endif

    if current_scheme == max_schemes
        let next_scheme = 0
    else
        let next_scheme = current_scheme + 1
    endif

    exec ':colorscheme ' . color_schemes.schemes[next_scheme]
    exec ':set background=' . color_schemes.background[next_scheme]
    exec ':hi Statusline guibg=NONE gui=NONE'

    " Update Lightline
    if !exists('g:loaded_lightline')
	    return
	endif
    try
        let g:lightline.colorscheme = 
                    \ substitute(substitute(color_schemes.lightline[next_scheme], '-', '_', 'g'), '256.*', '', '')
        call lightline#init()
        call lightline#colorscheme()
        call lightline#update()
    catch
    endtry

    call HighlightSyntax()

endfunction
nnoremap <leader>1 :call ChangeColorScheme()<cr>
" }}}
" }}}
" Abbreviations {{{

abbrev art !php artisan
abbrev mt !php artisan make:test
abbrev mm !php artisan make:model
abbrev mig !php artisan migrate<cr>
abbrev mc !php artisan make:controller
abbrev mmi !php artisan make:migration
abbrev ma !php artisan make:model $1 -m -c
abbrev mr !php artisan migrate:refresh && php artisan db:seed

" Automatically close HTML tags
iabbrev </ </<C-X><C-O>

" }}}
" Statusline {{{
" Display Options {{{
let s:statusline_options = {
            \   'active': {
            \     'left':  [ 'readonly', 'mode' , 'git' ],
            \     'right': [ 'time', 'project' ],
            \   },
            \   'components': {
            \     'readonly': 'Statusline_readonly()',
            \     'mode': 'Statusline_mode()',
            \     'git': 'Statusline_git()',
            \     'time': "strftime(%a\ %d\ %b\ %H:%M)",
            \     'project': 'Statusline_project()'
            \   },
            \   'seperators': {
            \     'readonly': ' %s',
            \     'mode': '%s >',
            \     'git': ' %s',
            \     'time': ' < ',
            \     'project': '[%s] '
            \   },
            \   'components_to_color': {
            \     'mode': 1,
            \     'project': 1
            \   },
            \   'theme_colors': {
            \     'default': [ '#abb2bf', '#61afef', '#98c379' ],
            \     'onedark': [ '#abb2bf', '#61afef', '#98c379' ],
            \     'materialbox': [ '#1d272b', '#fb8c00', '#43a047']
            \   },
            \   'mode_map': {
            \     'n': 'NORMAL', 'i': 'INSERT', 'R': 'REPLACE', 'v': 'VISUAL', 'V': 'VISUAL', "\<C-v>": 'V-BLOCK',
            \     'c': 'COMMAND', 's': 'SELECT', 'S': 'S-LINE', "\<C-s>": 'S-BLOCK', 't': 'TERMINAL'
            \   },
            \ }
" }}}
" Statusline Functions {{{
function! UpdateStatusline() abort
    set statusline=
    set statusline+=%{ChangeStatuslineColor()}
    set statusline+=%{StatuslineComponents('left')}%=%{StatuslineComponents('right')}
endfunction

function! StatuslineComponents(side) abort
    let output = ''

    " Fetch the components in the statusline dictionary
    for v in Fetch('active', a:side)
        let method = split(Fetch('components', v), '(')
        let component_color = ''

        " Check if the item should be specifically coloured
        if len(method) > 1 && method[1] != ')'
            let output .= StatuslineFormat(v, method[0], method[1])
            "let output .= StatuslineColor(v) . StatuslineFormat(v, method[0], method[1])
        else
            let output .= StatuslineFormat(v, method[0])
            "let output .= StatuslineColor(v) . StatuslineFormat(v, method[0])
        endif
    endfor

    return output
endfunction

function! StatuslineColor(component)
    for v in keys(s:statusline_options.components_to_color)
        if v == a:component
            return '%#Component_' . v . '#'
        endif
    endfor

    return '%#ComponentDefault#'
endfunction

function! StatuslineFormat(...)
    let output = ''
    let seperator = Fetch('seperators', a:1)

    if a:0 > 2
        for param in split(a:3, ',')
            let value = call(a:2, [ param ], {})
        endfor
    else
        let value = call(a:2, [], {})
    endif

    " Remove any last )'s from the value
    let value = substitute(value, ')\+$', '', '')

    if seperator =~ '%s'
        let output = printf(seperator, value)
    else
        let output = value . seperator
    endif

    return output
endfunction

function! ChangeStatuslineColor() abort

    let s:mode_colors = []

    try
        for mode_color in Fetch('theme_colors', g:colors_name)
            let s:mode_colors += [mode_color]
        endfor
    catch
        try
            for mode_color in Fetch('theme_colors', 'default')
                let s:mode_colors += [mode_color]
            endfor
        catch
            let s:mode_colors = ['#e06c75'] + ['#e06c75'] + ['#e06c75']
        endtry
    endtry

    if (mode() ==# 'i')
        exec printf('hi StatusLine guifg=%s guibg=NONE gui=NONE', s:mode_colors[1])
    elseif (mode() =~# '\v(v|V)')
        exec printf('hi StatusLine guifg=%s guibg=NONE gui=NONE', s:mode_colors[2])
    else
        exec printf('hi StatusLine guifg=%s guibg=NONE gui=NONE', s:mode_colors[0])
    endif

    return ''
endfunction

function! ChangeStatuslineColor2() abort
    let s:mode_colors = []

    try
        for mode_color in Fetch('theme_colors', g:colors_name)
            let s:mode_colors += [mode_color]
        endfor
    catch
        try
            for mode_color in Fetch('theme_colors', 'default')
                let s:mode_colors += [mode_color]
            endfor
        catch
            let s:mode_colors = ['#e06c75'] + ['#e06c75'] + ['#e06c75']
        endtry
    endtry

    if (mode() ==# 'i')
        exec printf('hi ComponentDefault guifg=%s', s:mode_colors[1])
    elseif (mode() =~# '\v(v|V)')
        exec printf('hi ComponentDefault guifg=%s', s:mode_colors[2])
    else
        exec printf('hi ComponentDefault guifg=%s', s:mode_colors[0])
    endif

    for component in keys(s:statusline_options.components_to_color)
        if (mode() ==# 'i')
            exec printf('hi Component_%s guifg=%s', component, s:mode_colors[1])
        elseif (mode() =~# '\v(v|V)')
            exec printf('hi Component_%s guifg=%s', component, s:mode_colors[2])
        else
            exec printf('hi Component_%s guifg=%s', component, s:mode_colors[0])
        endif
    endfor

    return ''
endfunction

" Fetch a value from the Statusline options
function! Fetch(key, value) abort
    return get(s:statusline_options[a:key], a:value, '')
endfunction

" }}}
" Component Functions {{{

" Show the mode in the statuslin
function! Statusline_mode() abort
    return get(s:statusline_options.mode_map, mode(), '')
endfunction

function! Statusline_project() abort
    return GetProjectDir()
endfunction

function! Statusline_git() abort
    let git = fugitive#head()
    if git != ''
        return ' '.fugitive#head()
    else
        return ''
    endif
endfunction

function! Statusline_readonly() abort
    if &readonly || !&modifiable
        return ' '
    else
        return ''
    endif
endfunction

" }}}
" Set The Statusline {{{
"augroup statusline
    "hi StatusLine guibg=NONE gui=NONE
    "autocmd!
    "autocmd WinEnter,BufWinEnter,FileType,ColorScheme,SessionLoadPost * call UpdateStatusline()
"augroup end

" }}}
" }}}
" vim:foldmethod=marker:foldlevel=0
