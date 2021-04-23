# Path to your dotfiles installation.
export DOTFILES=$HOME/.dotfiles

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.local/share/oh-my-zsh
export ZSH_CACHE_DIR=$ZSH/cache
export ZSH_CUSTOM=$ZSH/custom

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
ZSH_THEME=robbyrussell

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="false"

# Command execution timestamp
HIST_STAMPS="yyyy-mm-dd"

# Would you like to use another custom folder than $ZSH/custom?

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(asdf zsh-autosuggestions zsh-syntax-highlighting nix-shell)

# User configuration

# Preferred editor for local and remote sessions
if [ "$SSH_CONNECTION" ]; then
    export EDITOR='nvim'
else
    export EDITOR='code'
fi

# Load XDebug
export XDEBUG_CONFIG="idekey=VSCODE"

# Load the shell dotfiles:
for file in ~/.{aliases,functions,path}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done

# Load pyenv
# if command -v pyenv 1>/dev/null 2>&1; then
#  eval "$(pyenv init -)"
#  eval "$(pyenv virtualenv-init -)"
#fi

# Change the default starship location
export STARSHIP_CONFIG=~/.config/starship/starship.toml

# Activate Oh-My-Zsh
source $ZSH/oh-my-zsh.sh

# Use asdf for vm management
. /usr/local/opt/asdf/asdf.sh

# Use  starship for a beautiful prompt
eval "$(starship init zsh)"

# Remove any duplicates in the path
typeset -U path

# added by Nix installer
if [ -e /Users/Oli/.nix-profile/etc/profile.d/nix.sh ]; then . /Users/Oli/.nix-profile/etc/profile.d/nix.sh; fi
