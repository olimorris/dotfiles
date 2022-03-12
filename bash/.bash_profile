# Load the shell dotfiles, and then some:
# for file in ~/.{aliases,functions,path,env}; do
#   [ -r "${file}" ] && [ -f "${file}" ] && source "${file}"
# done;

# Load our env file - Even allow for variable expansion
# As per: https://gist.github.com/mihow/9c7f559807069a03e302605691f85572#gistcomment-3928443
# if [ -f .env ]; then
#     export $(echo $(cat .env | sed 's/#.*//g'| xargs) | envsubst)
# fi

# Load the z binary.
# . `brew --prefix`/etc/profile.d/z.sh

# Load bash completion
# if [ -f $(brew --prefix)/etc/bash_completion ]; then
#     . $(brew --prefix)/etc/bash_completion
# fi

# . "$HOME/.cargo/env"
