################################################################################
# Zsh Config
################################################################################

ZSH=$HOME/.local/share/zsh
PLUGIN_DIR=$ZSH/plugins

# History
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS
setopt HIST_VERIFY
setopt AUTOPARAMSLASH            # tab completing directory appends a slash
setopt SHARE_HISTORY             # Share your history across all your terminal windows
setopt EXTENDED_HISTORY          # Write the history file in the ':start:elapsed;command' format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits

# Store a lot of history
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history

# Cycle through history based on what I have already typed
# https://superuser.com/a/585004
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search   # Up
bindkey "^[[B" down-line-or-beginning-search # Down

################################################################################
# Plugins
################################################################################

# Initialize zshcompletions
fpath=($PLUGIN_DIR/zsh-completions/src $fpath)
autoload -U compinit
compinit
source $PLUGIN_DIR/zsh-completions/zsh-completions.plugin.zsh

source $PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh

# fzf
if [[ ! "$PATH" == *$(brew --prefix)/opt/fzf/bin* ]]; then
	export PATH="${PATH:+${PATH}:}$(brew --prefix)/opt/fzf/bin"
fi
[[ $- == *i* ]] && source "$(brew --prefix)/opt/fzf/shell/completion.zsh" 2>/dev/null
source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"

# asdf
source $(brew --prefix)/opt/asdf/libexec/asdf.sh

# Starship - Change the default starship location
export STARSHIP_CONFIG=~/.config/starship/starship.toml

############################### AUTO-COMPLETIONS ###############################

# Colorize completions using default `ls` colors.
zstyle ':completion:*' list-colors ''

# Enable keyboard navigation of completions in menu
# (not just tab/shift-tab but cursor keys as well):
zstyle ':completion:*' menu select

# Added by running `compinstall`
zstyle ':completion:*' expand suffix
zstyle ':completion:*' file-sort modification
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' list-suffixes true
# End of lines added by compinstall

##################################### EVALS ####################################
eval "$(thefuck --alias)"
eval "$(starship init zsh)"
