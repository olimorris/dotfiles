set -g fish_greeting ""

# Variables
set -x GPG_TTY (tty)
set -x EDITOR nvim
set -x DOTNET_CLI_TELEMETRY_OPTOUT 1
set -x HOMEBREW_NO_ANALYTICS 1
set -x GOPATH "$HOME/.go"
set -x EXTRAS "$HOME/.cache/nvim-new/onedarkpro_dotfiles/extras"

 # Paths
fish_add_path -p "$(brew --prefix rustup)/bin" "$(brew --prefix)/bin" "$HOME/.cargo/bin" "$HOME/.dotfiles/bin" "$HOME/.local/share/nvim/mason/bin" "$HOME/.local/bin" "$GOPATH/bin"

function theme
  set -f VARIANT "$(cat /tmp/oli-theme)"
  set -f FORMAT "$EXTRAS/fish/%s.fish"

  if [ "$VARIANT" = "light" ]
    set -gx THEME "onedarkpro_onelight"
  else
    set -gx THEME "onedarkpro_vaporwave"
  end

  source $(printf $FORMAT $THEME)
end

source $HOME/.config/fish/aliases.fish
source $HOME/.config/fish/functions.fish
source $HOME/.config/fish/fish_prompt.fish

# History configuration
set -g fish_history_limit 10000
set -g fish_history_save_on_exit true

if status is-interactive
    load_env_vars ~/.env
    theme
    mise activate fish | source
    zoxide init fish | source
    source $HOME/.config/fish/fzf.fish
end

