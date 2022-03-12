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
    section 'Using Dotbot to restore configs'

    run %( ./install )
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
    section 'Using Dotbot to put configs back'

    run %( ./uninstall )
  end
end

namespace :update do
  desc 'Update Dotbot'
  task :dotbot do
    run %( git submodule update --remote dotbot )
  end
end
