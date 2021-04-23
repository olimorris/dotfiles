# Load the shell dotfiles, and then some:
for file in ~/.{aliases,functions,path}; do
  [ -r "${file}" ] && [ -f "${file}" ] && source "${file}"
done;
unset file;

# Load the z binary.
# . `brew --prefix`/etc/profile.d/z.sh

# Load bash completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi

export PATH="$HOME/.poetry/bin:$PATH"
if [ -e /Users/Oli/.nix-profile/etc/profile.d/nix.sh ]; then . /Users/Oli/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer
