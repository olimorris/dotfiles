# Load the shell dotfiles, and then some:
for file in ~/.{aliases,functions,path}; do
  [ -r "${file}" ] && [ -f "${file}" ] && source "${file}"
done;
unset file;

# Load the z binary.
# . `brew --prefix`/etc/profile.d/z.sh

# Load bash completion
# if [ -f $(brew --prefix)/etc/bash_completion ]; then
#     . $(brew --prefix)/etc/bash_completion
# fi

export PATH="$HOME/.poetry/bin:$PATH"
