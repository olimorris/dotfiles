namespace :install do
  desc 'Install Neovim'
  task :neovim do
    section 'Installing Neovim'

    unless testing?
      run %( bob install stable )
      run %( bob install nightly )
      # run %( bob use nightly )
      # time = Time.new.strftime('%s')
      # run %( git clone --depth 1 --branch nightly https://github.com/neovim/neovim ~/.neovim/#{time} )
      # run %( rm -rf /opt/homebrew/bin/nvim )
      # run %( rm -rf /usr/local/bin/nvim )
      # run %( rm -rf /usr/local/share/nvim )
      # run %( \(cd ~/.neovim/#{time} && make CMAKE_BUILD_TYPE=RelWithDebInfo && make install\) )
      # run %( ln -s ~/.neovim/#{time} ~/.neovim/latest )
    end
  end

  # As per:
  # https://blog.backtick.consulting/neovims-built-in-lsp-with-ruby-and-rails/
  desc 'Install Rails YARD directives'
  task :rails do
    section 'Installing Rails YARD directives'

    run %( git clone https://gist.github.com/castwide/28b349566a223dfb439a337aea29713e ~/.dotfiles/misc/enhance-rails-intellisense-in-solargraph )
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
end

namespace :update do
  desc 'Update Neovim'
  task :neovim do
    section 'Updating Neovim'

    unless testing?
      run %( bob update )
      # run %( rm ~/.neovim/backup )
      # run %( mv ~/.neovim/latest ~/.neovim/backup )
      # Rake::Task['install:neovim'].invoke
    end
  end

  # desc 'Update Neovim plugins'
  # task :neovim_plugins do
  #   section 'Updating Neovim plugins'
  #
  #   run %( nvim --headless "+Lazy! sync" +qa )
  # end

  desc 'Update Rails YARD directives'
  task :rails do
    section 'Updating Rails YARD directives'

    run %( git -C ~/.dotfiles/misc/enhance-rails-intellisense-in-solargraph pull )
  end

  desc 'Update Vim plugins'
  task :vim do
    section 'Updating Vim plugins'

    run %( vim +PlugUpdate +qall ) unless testing?
  end
end

namespace :rollback do
  desc 'Rollback Neovim'
  task :neovim do
    section 'Rolling back Neovim'

    unless testing?
      run %( bob rollback )
      # run %( rm -rf /usr/local/bin/nvim )
      # run %( rm -rf /opt/homebrew/bin/nvim )
      #
      # # Delete the most recent folder
      # run %( cd ~/.neovim & rm -rf .DS_Store)
      # run %( (cd ~/.neovim && ls -Art | tail -n 1 | xargs rm -rf) )
      #
      # # Restore Neovim from the previous nightly build
      # run %( (cd ~/.neovim && ls -Art | fgrep -v .DS_Store | tail -n 1 | xargs -I{} cp -s ~/.neovim/1705399006/build/bin/nvim /usr/local/bin) )
    end
  end
end

namespace :uninstall do
  desc 'Uninstall Neovim'
  task :neovim do
    section 'Uninstalling Neovim'

    unless testing?
      run %( bob erase )
      # run %( rm ~/.neovim/backup )
      # run %( mv ~/.neovim/latest ~/.neovim/backup )
      # run %( rm -rf /usr/local/bin/nvim )
      # run %( rm -rf /opt/homebrew/bin/nvim )
    end
  end
end
