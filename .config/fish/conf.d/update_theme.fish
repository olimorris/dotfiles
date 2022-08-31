function update_theme --on-variable macOS_Theme
    if [ "$macOS_Theme" = "light" ]
        set -a FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color bg:'#fafafa',bg+:'#fafafa',fg:'#6a6a6a'
        set -a FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color fg+:'#9a77cf',hl:'#1da912',hl+:'#1da912'
        set -a FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color preview-bg:'#fafafa',preview-fg:'#6a6a6a'
        set -a FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color border:'#6a6a6a',gutter:'#fafafa',header:'#1da912'
        set -a FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color info:'#1da912',marker:'#e05661',pointer:'#9a77cf'
        set -a FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color prompt:'#eea825',spinner:'#118dc3'
    else
        set -a FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color bg:'#282c34',bg+:'#282c34',fg:'#abb2bf'
        set -a FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color fg+:'#c678dd',hl:'#98c379',hl+:'#98c379'
        set -a FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color preview-bg:'#282c34',preview-fg:'#abb2bf'
        set -a FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color border:'#abb2bf',gutter:'#282c34',header:'#98c379'
        set -a FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color info:'#98c379',marker:'#e06c7f',pointer:'#c678dd'
        set -a FZF_DEFAULT_OPTS $FZF_DEFAULT_OPTS --color prompt:'#e5c07b',spinner:'#61afef'
    end
end
