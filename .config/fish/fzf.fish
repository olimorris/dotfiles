set -x FZF_DEFAULT_OPTS
set -a FZF_DEFAULT_OPTS --height=70%
# set -a FZF_DEFAULT_OPTS --multi
set -a FZF_DEFAULT_OPTS --border
# set -a FZF_DEFAULT_OPTS --preview-window=:hidden
set -a FZF_DEFAULT_OPTS --history=$HOME/.fzf_history
# set -a FZF_DEFAULT_OPTS --bind=ctrl-t:top
set -a FZF_DEFAULT_OPTS --marker='✓'

if [ "$macOS_Theme" = light ]
    set FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color bg:'#fafafa',bg+:'#fafafa',fg:'#6a6a6a'
    set FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color query:'#6a6a6a',fg+:'#9a77cf',hl:'#118dc3',hl+:'#118dc3'
    set FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color preview-bg:'#fafafa',preview-fg:'#6a6a6a'
    set FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color border:'#6a6a6a',gutter:'#fafafa',header:'#1da912'
    set FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color info:'#1da912',marker:'#e05661',pointer:'#eea825'
    set FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color prompt:'#9a77cf',spinner:'#118dc3',separator:'#6a6a6a'
    set FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color query:regular
else if [ "$macOS_Theme" = dark ]
    set FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color bg:'#282c34',bg+:'#282c34',fg:'#abb2bf'
    set FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color query:'#abb2bf',fg+:'#c678dd',hl:'#61afef',hl+:'#61afef'
    set FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color preview-bg:'#282c34',preview-fg:'#abb2bf'
    set FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color border:'#abb2bf',gutter:'#282c34',header:'#98c379'
    set FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color info:'#98c379',marker:'#e06c7f',pointer:'#e5c07b'
    set FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color prompt:'#c678dd',spinner:'#61afef',separator:'#abb2bf'
    set FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color query:regular
end

set -g fzf_fd_opts --hidden --no-ignore --exclude=.git --exclude=Library
