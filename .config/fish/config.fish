set -g fish_greeting ""

# Variables
set -x GPG_TTY (tty)
set -x EDITOR nvim
set -x DOTNET_CLI_TELEMETRY_OPTOUT 1
set -x HOMEBREW_NO_ANALYTICS 1
set -x GOPATH "$HOME/Code/Go"
set -x STARSHIP_CONFIG "$HOME/.config/starship/starship.toml"
# set -gx macOS_Theme (cat $HOME/.color_mode | string collect)

set -g fish_color_param cyan
set -g fish_color_normal black
set -g fish_color_error red
set -g fish_color_comment gray
set -g fish_color_autosuggestion gray
set -g fish_pager_color_completion blue --bold

# if [ "$macOS_Theme" = light ]
#     set -x LS_COLORS "vivid generate $HOME/.config/vivid/onelight.yml"
# else
#     set -x LS_COLORS "vivid generate $HOME/.config/vivid/onedark.yml"
# end

 # Paths
fish_add_path -p /opt/homebrew/sbin /opt/homebrew/bin "$HOME/.cargo/bin" "$HOME/.dotfiles/bin" "$HOME/.local/share/nvim/mason/bin" "$HOME/.local/share/bob/nvim-bin"

source $HOME/.config/fish/fzf.fish
source $HOME/.config/fish/aliases.fish
source $HOME/.config/fish/functions.fish

if status is-interactive
    load_env_vars ~/.env

    # Cache zoxide init output
    source ~/.cache/zoxide.fish 2>/dev/null; or begin
        zoxide init fish > ~/.cache/zoxide.fish
        source ~/.cache/zoxide.fish
    end

    starship init fish | source
end
