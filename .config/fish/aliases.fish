# Docker
alias dl='docker ps'
alias dc='docker-compose'
alias dv='docker volume ls'
alias dce='docker-compose exec'
alias dcs='docker-compose stop'
alias dcd='docker-compose down'
alias dcb='docker-compose build'
alias dcu='docker-compose up -d'
alias dlog='docker-compose logs -f'
alias dx='docker system prune -a -f'
alias dub='docker-compose up -d --build'
alias dclear='docker rm -fv $(docker ps -aq)'
alias dcud='docker-compose -f docker-compose.dev.yml up -d'
alias dcsd='docker-compose -f docker-compose.dev.yml stop'
alias dcup='docker-compose -f docker-compose.prod.yml up -d'
alias dcsp='docker-compose -f docker-compose.prod.yml stop'

# Dotfiles
alias dot='dotfile_tasks'
alias ed='nvim $HOME/.dotfiles'
alias up='cd $HOME/.dotfiles && rake sync'
alias backup='cd $HOME/.dotfiles && rake backup'
alias clean='ruby $HOME/.dotfiles/commands/clean_up.rb'
alias icons='python $HOME/.dotfiles/commands/seticons.py'
alias cleanup='ruby $HOME/.dotfiles/commands/clean_up.rb $HOME/Downloads'

# Fish
alias fi='fisher install'
alias fl='fisher list'
alias fu='fisher update'
alias fr='fisher remove'

# Git
alias lg='lazygit'
alias ga='git add'
alias gp='git pull'
alias gaa='git add .'
alias gst='git status'
alias gc='git commit -m'
alias gnb='git checkout -b'
alias gpu='git push origin master'
alias gdm='git checkout -b dev-master'
alias nah='git reset --hard && git clean -df'
alias gfix='git rm -r --cached . && git add .'

# Homebrew
alias br='brew remove'
alias bu='brew update'
alias bs='brew search'
alias bi='brew install'
alias bupg='brew upgrade && brew cleanup'

# Mac
alias code='open $argv -a "Visual Studio Code"'
alias reloadapps="defaults write com.apple.dock ResetLaunchPad -bool true; killall Dock"

# Misc
alias ls='ls --color=auto'
alias fk='fuck' # Overwrite mistakes
alias fck='fuck'
alias etxt='extract-text'
alias wifi='wifi-password'
alias div='print_divider'
alias dm='color-mode dark'
alias lm='color-mode light'
alias essh='nvim $HOME/.ssh/config'
alias chmodall='sudo chmod -R 0777'
alias copyssh='pbcopy < $HOME/.ssh/$1'
alias rk='pgrep kitty | xargs kill -SIGUSR1'
alias dotbot='cd $HOME/.dotfiles && ./dotbot_install'
alias dotup='cd $HOME/.dotfiles && git submodule update --remote dotbot'
alias mssh='ruby $HOME/.dotfiles/commands/ssh.rb'
alias sep='ruby $HOME/.dotfiles/commands/make_separator.rb'
alias deploy="ssh DigitalOcean 'bash -s' < deploy.sh"

# Neovim / Vim
alias vi='nvim'
alias vim='/opt/homebrew/bin/vim'
alias nvu='cd $HOME/.dotfiles && rake update:neovim && prevd'

# PHP
alias art='php artisan'
alias sail='vendor/bin/sail up'
alias cu='composer update'
alias ci='composer install'
alias p='vendor/bin/phpunit'
alias tm='vendor/bin/phpunit'
alias sphp='brew-php-switcher'
alias csu='composer self-update'
alias phpunit='vendor/bin/phpunit'
alias cda='composer dump-autoload'
alias cgu='composer global update'
alias cor='vendor/bin/codecept run'
alias clearlogs='sudo echo -n -f >'
alias pc='clear && vendor/bin/phpunit'
alias tf='vendor/bin/phpunit --filter='
alias phplogs='sudo tail -f /usr/local/var/log/* /usr/local/var/log/nginx/* $HOME/.valet/Log/* /usr/local/opt/php71/var/log/*'

# Python
alias jup='jupyter notebook'
alias pipb='pip freeze > $HOME/.dotfiles/PIP.txt'
alias pipi='pip install -r $HOME/.dotfiles/PIP.txt'
alias jupr="jupyter notebook --NotebookApp.allow_origin='https://colab.research.google.com' --port=9090 --no-browser"

# Rails
alias r='bin/rails'
alias rr='rails routes'
alias rrg='rails routes | grep'
alias rd='rails destroy'
alias rc='rails console'
alias rdb='rails dbconsole'
alias rcs='rails console --sandbox'
alias rs='rails server -p 3001'
alias rsd='rails server --debugger'
alias rsp='rails server --port'
alias rsb='rails server --bind'
alias rup='rails app:update'
alias rds='rails db:setup'
alias rdm='rails db:migrate'
alias rdmr='rails db:migrate:redo'
# alias rg='rails generate'
alias rgm='rails generate model'
alias rgc='rails generate controller'
alias rgmi='rails generate migration'
alias rtest='tail -f log/test.log'
alias rdev='tail -f log/development.log'
alias rprod='tail -f log/production.log'

# Ruby
alias rt='rake test'
alias sb='$HOME/.local/share/nvim/mason/packages/solargraph/bin/solargraph bundle'
alias ug='gem update --system && gem update'

# Shell
alias c='clear'
alias tags='ctags -R'
alias ea='nvim $HOME/.config/fish/aliases.fish'
alias et='nvim $HOME/.config/tmux/tmux.conf'
alias src='exec fish && source $HOME/.config/fish/config.fish && fish_logo'
alias reloaddns='dscacheutil -flushcache && sudo killall -HUP mDNSResponder'

# Shell navigation
alias ..='cd ..'
alias bk='cd -'
alias home='cd $HOME'
alias ...='cd ../..'
alias desk='cd $HOME/Desktop'
alias ....='cd ../../..'
alias .....='cd ../../../..'

# Tmux
alias tsa='tmux-sendall'                # Send a command to all windows and panes that don't have a process running
alias tks='tmux kill-server'            # Kill everything
alias tl='tmux list-sessions'           # List all of the open tmux sessions
alias tn='tmux new-session -s'          # Create a new tmux session - Specify a name
alias tk='tmux kill-session -a'         # Kill all of the OTHER tmux sessions
alias t='tmux attach || tmux new-session'   # Attaches tmux to the last session; creates a new session if none exists.
alias tpi='$HOME/.config/tmux/plugins/tpm/bin/install_plugins' # Installs Tmux plugins
alias tpu='$HOME/.config/tmux/plugins/tpm/bin/update_plugins all' # Updates all Tmux plugins
