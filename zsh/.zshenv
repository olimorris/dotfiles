################################################################################
# Path
################################################################################

path+=(
    "${HOME}/.dotfiles/bin"
    "${HOME}/.node/bin"
    "${HOME}/.cargo/bin"
)

if which yarn >/dev/null; then
  path+=("$(yarn global bin)")
fi

if which go >/dev/null; then
  export GOPATH=$HOME/go
  path+=("$GOPATH/bin")
fi

# Remove any duplicates in the path
typeset -U path

################################################################################
# SOURCE FILES
################################################################################

for file in ~/.{aliases,functions}; do
    [ -r "$file" ] && [ -f "$file" ] && source "$file"
done

DOTFILES=$HOME/.dotfiles

################################################################################
# Environment variables
################################################################################

# Preferred editor for local and remote sessions
if [ "$SSH_CONNECTION" ]; then
    export EDITOR='nvim'
else
    export EDITOR='nvim'
fi

# Load Cargo package manager
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# Allow compilers to find Ruby
export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"

# Allow pkg-config to find Ruby
export PKG_CONFIG_PATH="/opt/homebrew/opt/ruby/lib/pkgconfig"

# Load our .env file
# As per: https://gist.github.com/mihow/9c7f559807069a03e302605691f85572#gistcomment-3903516
if [ -f .env ]; then
    export $(grep -v '^#' .env | xargs)
fi

################################################################################
# Others
################################################################################

# fzf
if grep -q light "${HOME}/.color_mode"; then
    FZF_DEFAULT_OPTS="--color=hl:#1da912,gutter:#fafafa,pointer:#9a77cf,hl+:#1da912,fg:#6a6a6a,fg+:#9a77cf,marker:#e05661,border:#6a6a6a,prompt:#eea825,header:#e05661,bg+:#fafafa,info:#bebebe,spinner:#118dc3 --reverse --history=$HOME/.fzf_history --bind=ctrl-t:top --border --multi"
else
    FZF_DEFAULT_OPTS="--color=hl:#98c379,gutter:#282c34,pointer:#c678dd,hl+:#98c379,fg:#abb2bf,fg+:#c678dd,marker:#e06c75,border:#abb2bf,prompt:#e5c07b,header:#e06c75,bg+:#282c34,info:#5c6370,spinner:#61afef --reverse --history=$HOME/.fzf_history --bind=ctrl-t:top --border --multi"
fi
