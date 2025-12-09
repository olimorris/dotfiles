set -x FZF_DEFAULT_OPTS
set -a FZF_DEFAULT_OPTS --height=70%
set -a FZF_DEFAULT_OPTS --border=none
set -a FZF_DEFAULT_OPTS --history=$HOME/.fzf_history
set -a FZF_DEFAULT_OPTS --marker='✓'
set -a FZF_DEFAULT_OPTS --highlight-line
source "$EXTRAS/fzf_fish/$THEME.fish"
set -g fzf_fd_opts --hidden --no-ignore --exclude=.git --exclude=Library
