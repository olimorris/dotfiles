set -g fish_greeting ""

# Variables
set -x GPG_TTY (tty)
set -x EDITOR nvim
set -x DOTNET_CLI_TELEMETRY_OPTOUT 1
set -x HOMEBREW_NO_ANALYTICS 1
set -x GOPATH "$HOME/.go"

 # Paths
fish_add_path -p "$(brew --prefix rustup)/bin" "$(brew --prefix)/bin" "$HOME/.cargo/bin" "$HOME/.dotfiles/bin" "$HOME/.local/share/nvim/mason/bin" "$HOME/.local/share/bob/nvim-bin" "$HOME/.local/bin" "$GOPATH/bin"

function theme
  set -f VARIANT "$(cat /tmp/oli-theme)"
  set -f FORMAT "$HOME/.cache/nvim/onedarkpro_dotfiles/extras/fish/%s.fish"

  if [ "$VARIANT" = "light" ]
    set -f THEME "onedarkpro_onelight"
  else
    set -f THEME "onedarkpro_vaporwave"
  end

  source $(printf $FORMAT $THEME)
end

source $HOME/.config/fish/fzf.fish
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
    zoxide init --cmd dot fish | source
end

