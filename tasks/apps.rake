namespace :install do
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

  desc 'Install Neovim'
  task :neovim do
    section 'Installing Neovim'

    run %( nvimv install stable ) unless testing?
    run %( nvimv install nightly ) unless testing?
    run %( nvim --headless +'OneDarkProExtras' +qall)
  end
end

namespace :update do
  desc 'Update Vim plugins'
  task :vim do
    section 'Updating Vim plugins'

    run %( vim +PlugUpdate +qall ) unless testing?
  end

  desc 'Update Neovim'
  task :neovim do
    section 'Updating Neovim'

    run %( nvimv upgrade stable ) unless testing?
    run %( nvimv upgrade nightly ) unless testing?
    run %( nvim --headless +'OneDarkProExtras' +qall)
  end
end
