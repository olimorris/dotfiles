set -x FZF_DEFAULT_OPTS
set -a FZF_DEFAULT_OPTS --height=80%
set -a FZF_DEFAULT_OPTS --multi
set -a FZF_DEFAULT_OPTS --border
set -a FZF_DEFAULT_OPTS --preview-window=:hidden
set -a FZF_DEFAULT_OPTS --inline-info
set -a FZF_DEFAULT_OPTS --history=$HOME/.fzf_history
set -a FZF_DEFAULT_OPTS --bind=ctrl-t:top
set -a FZF_DEFAULT_OPTS --pointer='▶' --marker='✓'

# FZF theming is in the conf.d/update_theme.fish file

set fzf_fd_opts --hidden --no-ignore --exclude=.git --exclude=Library
