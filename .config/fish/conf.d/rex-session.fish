status is-interactive; or return
set -q REX_BLOCK; or return

# Runs in the background so a slow Rex server never holds up the prompt after a cd
function __rex_session_name --on-variable PWD
    $HOME/.dotfiles/bin/rex-name-session --sync >/dev/null 2>&1 &
    disown
end

__rex_session_name
