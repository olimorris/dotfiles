PIP_FILE = File.expand_path('~/.dotfiles/misc/packages/python_pip.txt', __dir__)
NPM_FILE = File.expand_path('~/.dotfiles/misc/packages/npm_packages.txt', __dir__)
GEMS_FILE = File.expand_path('~/.dotfiles/misc/packages/ruby_gems.txt', __dir__)
FONT_PATH = File.expand_path('~/.dotfiles/misc/ui/fonts')

namespace :backup do
  desc 'Backup PIP files'
  task :pip do
    section 'Backing up PIP files'

    run %( pip3 freeze \> #{PIP_FILE} )
  end

  desc 'Backup NPM files'
  task :npm do
    section 'Backing up NPM files'

    run %( npm -g upgrade )
    run %( npm list --global --parseable --depth=0 | sed '1d' | awk '\{gsub\(/\\/.*\\//,"",$1\); print\}' \> #{NPM_FILE} )
  end

  desc 'Backup Ruby Gems'
  task :gems do
    section 'Backing up Ruby Gems'

    run %( gem list --no-versions | sed '1d' | awk '\{gsub\(/\\/.*\\//,"",$1\); print\}' \> #{GEMS_FILE} )
  end
end

namespace :install do
  desc 'Install fonts'
  task :fonts do
    section 'Installing fonts'

    unless testing?
      Dir.foreach(FONT_PATH) do |font|
        next if ['.', '..', '.DS_Store'].include?(font)

        escaped_path = FONT_PATH.gsub("'") { "\\'" }
        escaped_path = escaped_path.gsub(' ') { '\\ ' }
        font = font.gsub(' ') { '\\ ' }
        run %( cp #{escaped_path}/#{font} ~/Library/Fonts )
      end
    end
  end


  desc 'Install macOS Configurations'
  task :macos do
    section 'Installing macOS Configurations'

    run %( sh ./commands/macos )
  end

  desc 'Install Servers'
  task :servers do
    section 'Installing servers'

    unless testing?
      run %( asdf plugin add python )
      run %( asdf install python 2.7.18 )
      run %( asdf install python 3.10.0 )
      run %( asdf global python 3.10.0 2.7.18 )
      run %( ~/.asdf/shims/python -m pip install --upgrade pip )
      run %( ~/.asdf/shims/python -m pip install pynvim )
      run %( ~/.asdf/shims/python2 -m pip install --upgrade pip )
      run %( ~/.asdf/shims/python2 -m pip install pynvim )

      run %( asdf plugin add ruby )
      run %( asdf install ruby 3.1.1 )
      run %( asdf install ruby 2.7.4 )
      run %( asdf global ruby 3.1.1 )

      run %( asdf plugin add lua )
      run %( asdf install lua 5.4.3 )
      run %( asdf global lua 5.4.3 )

      run %( asdf plugin add postgres )
      run %( asdf install postgres 14.0 )
      run %( asdf global postgres 14.0 )
      run %( ~/.asdf/installs/postgres/14.0/bin/pg_ctl -D ~/.asdf/installs/postgres/14.0/data -l logfile start )

      run %( asdf plugin add nodejs )
      run %( asdf install nodejs latest )
      run %( asdf global nodejs latest )
    end
  end

  desc 'Install Neovim'
  task :neovim do
    section 'Installing Neovim'

    unless testing?
      time = Time.new.strftime('%s')
      run %( git clone --depth 1 --branch nightly https://github.com/neovim/neovim ~/.neovim/#{time} )
      run %( rm -rf /usr/local/bin/nvim )
      run %( rm -rf /opt/homebrew/bin/nvim )
      run %( \(cd ~/.neovim/#{time} && make CMAKE_BUILD_TYPE=RelWithDebInfo && make install\) )
      run %( ln -s ~/.neovim/#{time} ~/.neovim/latest )
    end
  end

  desc 'Install Vim plugins'
  task :vim do
    section 'Installing Vim plugins'

    unless testing?
      run %( mkdir ~/.vim/swp )
      run %( mkdir ~/.vim/undo )
      run %( curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim )
      run %( vim +PlugInstall +qall )
    end
  end

  desc 'Install PIP files'
  task :pip do
    section 'Installing PIP files'

    run %( pip3 install -r #{PIP_FILE} )
  end

  desc 'Install NPM files'
  task :npm do
    section 'Installing NPM files'

    run %( xargs npm install --global \< #{NPM_FILE} )
  end

  desc 'Install Ruby Gems'
  task :gems do
    section 'Installing Ruby Gems'

    run %( xargs gem install \< #{GEMS_FILE} )
  end

  desc 'Install Rust, Cargo and packages'
  task :cargo do
    section 'Installing Rust, Cargo and packages'

    # Install Rust and Cargo
    run %( curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh )

    # Install packages
    run %( cargo install cargo-update )
  end

  desc 'Install Fish'
  task :fish do
    section 'Installing Fish and plugins'

    run %( curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher )
    run %( fisher list | fisher install )
    run %( echo $(where fish) | sudo tee -a /etc/shells )
    run %( chsh -s $(where fish) )
  end

  desc 'Install true color support for Tmux and Alacritty'
  task :tmux_color do
    section 'Installing Tmux and Alacritty colors'

    run %( curl -LO https://invisible-island.net/datafiles/current/terminfo.src.gz && gunzip terminfo.src.gz )
    run %( /usr/bin/tic -xe tmux-256color terminfo.src )
    run %( /usr/bin/tic -xe alacritty-direct,tmux-256color terminfo.src )
    run %( rm terminfo.src )
  end

  desc 'Install Tmux plugins'
  task :tmux do
    section 'Installing Tmux plugins'

    run %( rm -rf ~/.config/tmux/plugins )
    run %( git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm )
    run %( ~/.config/tmux/plugins/tpm/bin/install_plugins )
  end

  desc 'Install Launch Agents'
  task :launchagents do
    section 'Installing Launch Agents'

    run %( launchctl load -w ~/Library/LaunchAgents/oli.color-mode-notify.plist )
  end

  # As per:
  # https://blog.backtick.consulting/neovims-built-in-lsp-with-ruby-and-rails/
  desc 'Install Rails YARD directives'
  task :rails do
    section 'Installing Rails YARD directives'

    run %( git clone https://gist.github.com/castwide/28b349566a223dfb439a337aea29713e ~/.dotfiles/misc/enhance-rails-intellisense-in-solargraph )
  end

  desc 'Make dotfiles/bin executable'
  task :chmod_dots do
    section 'Making dotfiles/bin executable'

    run %( chmod -R +x ~/.dotfiles/bin/ )
  end

  desc 'Link dotfiles to the Git repository'
  task :git do
    section 'Linking dotfiles to the Git repository'

    run %( cd ~/.dotfiles && git init )
    run %( cd ~/.dotfiles && git remote add origin https://github.com/olimorris/dotfiles.git )
    run %( cd ~/.dotfiles && git fetch origin )
    run %( cd ~/.dotfiles && git reset origin/main )
  end

  desc 'Change Hammerspoon directory'
  task :hammerspoon do
    section 'Changing Hammerspoon directory'

    run %( defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua" )
  end
end

namespace :update do
  desc 'Update Neovim'
  task :neovim do
    section 'Updating Neovim'

    unless testing?
      run %( mv ~/.neovim/latest ~/.neovim/backup )
      Rake::Task['install:neovim'].invoke
    end
  end

  desc "Update Neovim plugins"
  task :neovim_plugins do
    section 'Updating Neovim plugins'

    run %( nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' )
  end


  desc 'Update Vim plugins'
  task :vim_plugins do
    section 'Updating Vim plugins'

    run %( vim +PlugUpdate +qall ) unless testing?
  end

  desc 'Update PIP files'
  task :pip do
    section 'Updating PIP files'

    run %( pip3 install --upgrade pip )
    run %( pip3 freeze \> #{PIP_FILE} )
    find_replace(PIP_FILE, '==', '>=')
    run %( pip3 install -r #{PIP_FILE} --upgrade )
  end

  desc 'Update NPM packages'
  task :npm do
    section 'Updating NPM'

    run %( npm install -g npm && npm update -g )
  end

  desc 'Update Ruby Gems'
  task :gems do
    section 'Updating Ruby Gems'

    run %( gem update --system && gem update )
  end

  desc 'Update Cargo packages'
  task :cargo do
    section 'Updating Cargo packages'

    run %( cargo install-update -a )
  end

  desc 'Update Fish'
  task :fish do
    section 'Updating Fish plugins'

    run %( fisher update )
  end

  desc 'Update Tmux plugins'
  task :tmux do
    section 'Updating Tmux plugins'

    run %( ~/.config/tmux/plugins/tpm/bin/update_plugins all )
  end

  desc 'Update Rails YARD directives'
  task :rails do
    section 'Updating Rails YARD directives'

    run %( git -C ~/.dotfiles/misc/enhance-rails-intellisense-in-solargraph pull )
  end

  desc 'Update Servers'
  task :servers do
    section 'Updating servers'

    run %( asdf plugin update --all )
  end
end

namespace :rollback do
  desc 'Rollback Neovim'
  task :neovim do
    section 'Rolling back Neovim'

    unless testing?
      run %( rm -rf /usr/local/bin/nvim )
      run %( rm -rf /opt/homebrew/bin/nvim )

      # Delete the most recent folder
      run %( cd ~/.neovim & rm -rf .DS_Store)
      run %( (cd ~/.neovim && ls -Art | tail -n 1 | xargs rm -rf) )

      # Restore Neovim from the previous nightly build
      run %( (cd ~/.neovim && ls -Art | fgrep -v .DS_Store | tail -n 1 | xargs -I{} cp -s ~/.neovim/{}/build/bin/nvim /usr/local/bin) )
    end
  end
end
