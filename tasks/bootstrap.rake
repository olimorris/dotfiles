namespace :backup do
  desc 'Backup dotfiles'
  task :mackup do
    section 'Using Mackup to backup configs'

    if ENV['DRY_RUN']
      puts "~> Chill! It's a dry run"
      system %( mackup backup --dry-run )
    else
      run %( mackup backup --force )
    end
  end
end

namespace :install do
  desc 'Install dotfiles'

  task :symlinks do
    section 'Creating symlinks'

    unless testing?
      run %( ln -s ~/Library/Mobile\ Documents/com~apple~CloudDocs/Code/ ~/Code )
      run %( ln -s ~/Library/Mobile\ Documents/com~apple~CloudDocs/Dotfiles/ ~/.dotfiles )
    end
  end

  task :xcode do
    section 'Installing XCode'

    run %( xcode-select --install )
  end

  task :mackup do
    section 'Installing Mackup'

    if !File.file?(File.expand_path('~/.mackup.cfg')) && !ENV['DRY_RUN']
      run %( ln -s #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER + File::SEPARATOR}.mackup.cfg #{'~' + File::SEPARATOR}.mackup.cfg )
      run %( ln -s #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER + File::SEPARATOR}.mackup #{'~' + File::SEPARATOR}.mackup )
    else
      puts '~> Already installed'
    end

    section 'Using Mackup to restore configs'

    if ENV['DRY_RUN']
      puts "~> Chill! It's a dry run"
      system %( mackup restore --dry-run )
    else
      run %( mackup restore --force )
    end
  end

  task :dotbot do
    section 'Using Dotbot to symlink dotfiles'

    run %( ./dotbot_install )
  end
end

namespace :uninstall do
  desc 'Uninstall dotfiles'

  task :mackup do
    section 'Using Mackup to put configs back'

    if ENV['DRY_RUN']
      puts '~> Just a dry run'
      system %( mackup uninstall --dry-run )
    else
      run %( mackup uninstall )
    end
  end

  task :dotbot do
    section 'Uninstall Dotbot and restoring dotfiles'

    run %( ./dotbot_uninstall )
  end
end

namespace :update do
  desc 'Update Dotbot'
  task :dotbot do
    section 'Updating Dotbot'
    run %( git submodule update --remote dotbot )
    run %( ./dotbot_install )
  end
end
