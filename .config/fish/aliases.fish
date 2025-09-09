# Dotfiles
alias dot='cd ~/.dotfiles'
alias ed='nvim ~/.dotfiles'
alias db='dotbot -c dotbot.conf.yaml'
alias up='cd ~/.dotfiles && rake sync'
alias backup='cd ~/.dotfiles && rake backup'
alias bf='cd ~/.dotfiles && rake backup:files'
alias cleanup='ruby ~/.dotfiles/commands/clean_up.rb ~/Downloads'

# Fish
alias fl='fisher list'
alias fu='fisher update'
alias fr='fisher remove'
alias fi='fisher install'

# Git
alias lg='lazygit'

# hledger
alias hs='hledger-forecast summarize -f $FINANCES/forecast.csv'
alias hfu='hledger-ui -f $FINANCES/actuals.journal -f $FINANCES/forecast.journal'
alias hf='hledger -f $FINANCES/actuals.journal -f $FINANCES/forecast.journal --auto'
alias hg='hledger-forecast generate -t $FINANCES/actuals.journal -f $FINANCES/forecast.csv -o $FINANCES/forecast.journal --force'
alias hb='hledger -f $FINANCES/actuals.journal -f $FINANCES/forecast.journal bal -M --tree --budget expenses -b "1 month ago" -e "2 months"'
alias hfs='hledger -f $FINANCES/actuals.journal -f $FINANCES/forecast.journal --forecast="this month".. --auto bal "^(ass|liab)" --tree -H -e "1 month"'

# Homebrew
alias bl='brew list'
alias br='brew remove'
alias bu='brew update'
alias bs='brew search'
alias bi='brew install'

# Mac
alias code='open $argv -a "Visual Studio Code"'
alias reloadapps="defaults write com.apple.dock ResetLaunchPad -bool true; killall Dock"

# Misc
alias ls='ls --color=auto'
alias dm='color-mode dark'
alias lm='color-mode light'
alias essh='nvim ~/.ssh/config'
alias chmodall='sudo chmod -R 0777'
alias copyssh='pbcopy < ~/.ssh/$1'
alias mssh='ruby ~/.dotfiles/commands/ssh.rb'
alias sep='ruby ~/.dotfiles/commands/make_separator.rb'

# Neovim / Vim
alias vim='/opt/homebrew/bin/vim'
alias nn='NVIM_APPNAME=nvim-new nvim'

# Python
alias jp='jupyter notebook'
alias pipb='pip freeze > ~/.dotfiles/PIP.txt'
alias pipi='pip install -r ~/.dotfiles/PIP.txt'
alias pypiu='rm -rf dist/* && python3 -m build && python3 -m twine upload dist/*'
alias pypiu_test='rm -rf dist/* && python3 -m build && python3 -m twine upload --repository testpypi dist/*'

# Shell
alias c='clear'
alias tags='ctags -R'
alias src='source ~/.config/fish/config.fish && fish_logo'
alias reloaddns='dscacheutil -flushcache && sudo killall -HUP mDNSResponder'

# Shell navigation
alias ..='cd ..'
alias bk='cd -'
alias home='cd ~'
alias ...='cd ../..'
alias ze='zoxide edit'
alias ....='cd ../../..'
alias desk='cd ~/Desktop'
alias .....='cd ../../../..'
