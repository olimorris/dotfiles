set -u fish_greeting ""

# Variables
set -x GPG_TTY (tty)
set -x EDITOR nvim
set -x DOTNET_CLI_TELEMETRY_OPTOUT 1
set -x HOMEBREW_NO_ANALYTICS 1
set -x GOPATH "$HOME/Code/Go"
set -x STARSHIP_CONFIG "$HOME/.config/starship/starship.toml"

# Paths
fish_add_path /opt/homebrew/bin/brew
fish_add_path /opt/homebrew/sbin
fish_add_path "$HOME/.cargo/bin"
fish_add_path "$HOME/.dotfiles/bin"
fish_add_path "$HOME/.local/share/nvim/mason/bin"

source $HOME/.config/fish/aliases.fish
source $HOME/.config/fish/functions.fish

if status is-interactive
    load_env_vars ~/.env
    thefuck --alias | source
    starship init fish | source

    set -gx ATUIN_NOBIND "true"
    atuin init fish | source
    bind \cr _atuin_search
end
