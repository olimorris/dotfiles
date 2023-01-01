namespace :backup do
  desc 'Backup app config'
  task :mackup do
    section 'Using Mackup to backup app configs'

    if ENV['DRY_RUN']
      puts "~> Chill! It's a dry run"
      system %( mackup backup --dry-run )
    else
      run %( mackup backup --force )
    end
  end

  desc 'Backup files'
  task :files do
    section 'Using RCLONE to backup files to Koofr'

    run %( rclone sync ~/Code koofr:Code --filter-from ~/.config/rclone/filter_list.txt )
    run %( rclone sync ~/.dotfiles koofr:.dotfiles --filter-from ~/.config/rclone/filter_list.txt )
    run %( rclone sync ~/Oli\'s\ Documents koofr:Oli\'s\ Documents --filter-from ~/.config/rclone/filter_list.txt )
  end
end

namespace :install do
  desc 'Install files'

  task :mackup do
    section 'Installing Mackup'

    if !File.file?(File.expand_path('~/.mackup.cfg')) && !ENV['DRY_RUN']
      run %( ln -s #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER + File::SEPARATOR}.mackup.cfg #{'~' + File::SEPARATOR}.mackup.cfg )
      run %( ln -s #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER + File::SEPARATOR}.mackup #{'~' + File::SEPARATOR}.mackup )
    else
      puts '~> Already installed'
    end

    section 'Using Mackup to restore app configs'

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

  task :files do
    section 'Linking folders to their Git repository'

    run %( cd ~/.dotfiles && git init )
    run %( cd ~/.dotfiles && git remote add origin https://github.com/olimorris/dotfiles.git )

    run %( cd ~/Code/Projects/onedarkpro.nvim && git init )
    run %( cd ~/Code/Projects/onedarkpro.nvim && git remote add origin https://github.com/olimorris/onedarkpro.nvim.git )

    run %( cd ~/Code/Projects/persisted.nvim && git init )
    run %( cd ~/Code/Projects/persisted.nvim && git remote add origin https://github.com/olimorris/persisted.nvim.git )

    run %( cd ~/Code/Projects/neotest-rspec && git init )
    run %( cd ~/Code/Projects/neotest-rspec && git remote add origin https://github.com/olimorris/neotest-rspec.git )

    run %( cd ~/Code/Projects/neotest-phpunit && git init )
    run %( cd ~/Code/Projects/neotest-phpunit && git remote add origin https://github.com/olimorris/neotest-phpunit.git )
  end
end

namespace :uninstall do
  desc 'Uninstall dotfiles'

  task :mackup do
    section 'Using Mackup to put app configs back'

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