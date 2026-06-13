set -g fish_greeting ""

# Variables
set -gx DOTNET_CLI_TELEMETRY_OPTOUT 1
set -gx EDITOR nvim
set -gx EXTRAS "$HOME/.cache/nvim/onedarkpro_dotfiles/extras"
set -gx GOPATH "$HOME/.go"
set -gx GPG_TTY (tty)
set -gx HOMEBREW_NO_ANALYTICS 1

# Paths
fish_add_path -p /opt/homebrew/opt/rustup/bin /opt/homebrew/bin ~/.cargo/bin ~/.dotfiles/bin ~/.local/share/nvim/mason/bin ~/.local/bin $GOPATH/bin

function theme
  test -f /tmp/oli-theme; or echo dark > /tmp/oli-theme

  read -l variant < /tmp/oli-theme
  if test "$variant" = light
    set -gx THEME onedarkpro_onelight
  else
    set -gx THEME onedarkpro_vaporwave
  end

  source "$EXTRAS/fish/$THEME.fish"
end

# History configuration
set -g fish_history_limit 10000

if status is-interactive
    source $HOME/.config/fish/aliases.fish
    source $HOME/.config/fish/functions.fish
    source $HOME/.config/fish/fish_prompt.fish
    load_env_vars ~/.env
    theme
    mise activate fish | source
    zoxide init fish | source
    source $HOME/.config/fish/fzf.fish
end

