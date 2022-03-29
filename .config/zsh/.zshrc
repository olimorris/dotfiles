################################################################################
# Zsh
################################################################################

ZSH=$HOME/.local/share/zsh
PLUGIN_DIR=$ZSH/plugins

ENABLE_CORRECTION="false"
HIST_STAMPS="yyyy-mm-dd"

################################################################################
# STARSHIP - For a beautiful prompt
################################################################################

# Change the default starship location
export STARSHIP_CONFIG=~/.config/starship/starship.toml

################################################################################
# Plugins
################################################################################

source $PLUGIN_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $PLUGIN_DIR/zsh-autosuggestions/zsh-autosuggestions.zsh
fpath=($PLUGIN_DIR/zsh-completions/src $fpath)

# fzf
if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
	export PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi
[[ $- == *i* ]] && source "/opt/homebrew/opt/fzf/shell/completion.zsh" 2>/dev/null
source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"

# asdf
source /opt/homebrew/opt/asdf/libexec/asdf.sh

eval "$(thefuck --alias)"
eval "$(starship init zsh)"

