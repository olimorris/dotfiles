#!/usr/bin/env bash
set -uo pipefail

# rex-sessionizer's picker, listing zoxide's directories by frecency instead of those under its work dir
# rex-sessionizer passes --work-dir and --current, which this ignores

selected=$(zoxide query --list | sed "s|^$HOME/|~/|" | fzf --prompt="project> " --header="Switch project") || exit 0

if ! rex do sessionizer_go path="$selected" >/dev/null; then
  read -r -p "Could not switch to $selected. Press Enter to close…"
fi
