
################################################################################
# OH MY ZSH
################################################################################

# Path to your oh-my-zsh installation.
ZSH=$HOME/.local/share/oh-my-zsh
ZSH_CACHE_DIR=$ZSH/cache
ZSH_CUSTOM=$ZSH/custom

# Don't need a theme as we're using Starship
# ZSH_THEME=robbyrussell

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="false"

# Command execution timestamp
HIST_STAMPS="yyyy-mm-dd"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    asdf
    fzf
    sudo
    thefuck
    tmux
    zsh-autosuggestions
    zsh-syntax-highlighting
)

################################ PLUGIN SETTINGS ###############################

# Tmux
ZSH_TMUX_AUTOCONNECT=true

################################ INIT OH MY ZSH ################################

# Activate Oh My Zsh
source $ZSH/oh-my-zsh.sh

################################################################################
# STARSHIP - For a beautiful prompt
################################################################################

# Change the default starship location
export STARSHIP_CONFIG=~/.config/starship/starship.toml

################################################################################
# Evals
################################################################################

eval "$(thefuck --alias)"
eval "$(starship init zsh)"