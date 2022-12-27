set -u fish_greeting ""

# Variables
set -x GPG_TTY (tty)
set -x EDITOR nvim
set -x DOTNET_CLI_TELEMETRY_OPTOUT 1
set -x HOMEBREW_NO_ANALYTICS 1
set -x GOPATH "$HOME/Code/Go"
set -x STARSHIP_CONFIG "$HOME/.config/starship/starship.toml"
set -gx macOS_Theme (cat $HOME/.color_mode | string collect)
set -x _ZO_DATA_DIR "$HOME/.local/share"

set fish_color_param cyan
set fish_pager_color_completion blue --bold
set fish_color_normal black
set fish_color_error red
set fish_color_comment gray
set fish_color_autosuggestion gray

if [ "$macOS_Theme" = light ]
    set -x LS_COLORS "vivid generate $HOME/.config/vivid/onelight.yml"
else if [ "$macOS_Theme" = dark ]
    set -x LS_COLORS "vivid generate $HOME/.config/vivid/onedark.yml"
end

# Paths
fish_add_path /opt/homebrew/bin/brew
fish_add_path /opt/homebrew/sbin
fish_add_path "$HOME/.cargo/bin"
fish_add_path "$HOME/.dotfiles/bin"
fish_add_path "$HOME/.local/share/nvim/mason/bin"

source $HOME/.config/fish/fzf.fish
source $HOME/.config/fish/aliases.fish
source $HOME/.config/fish/functions.fish

if status is-interactive
    load_env_vars ~/.env
    thefuck --alias | source
    zoxide init fish | source
    starship init fish | source
    source /opt/homebrew/opt/asdf/libexec/asdf.fish
end

