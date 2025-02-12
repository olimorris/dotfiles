namespace :backup do
  desc 'Backup app config'
  task :app_config do
    section 'Using Mackup to backup app configs'

    if ENV['DRY_RUN']
      puts "~> Chill! It's a dry run"
      system %( mackup backup --dry-run && mackup uninstall --dry-run )
    else
      run %( mackup backup --force && mackup uninstall --force )
    end
  end

  desc 'Backup files'
  task :files, [:progress] do |_t, args|
    run %( /bin/date -u )

    section 'Using RCLONE to backup files'

    dirs = {
      '.dotfiles' => "#{ENV['STORAGE_ENCRYPTED_FOLDER']}:dotfiles",
      'Code' => "#{ENV['STORAGE_ENCRYPTED_FOLDER']}:Code",
      'OliDocs' => "#{ENV['STORAGE_ENCRYPTED_FOLDER']}:Documents",
      'Downloads' => "#{ENV['STORAGE_ENCRYPTED_FOLDER']}:Downloads",
      'Documents' => "#{ENV['STORAGE_ENCRYPTED_FOLDER']}:ICloud_Docs"
    }

    flag = ' -P' if args[:progress]
    filter = ' --filter-from ~/.config/rclone/filter_list.txt'

    dirs.each do |local, remote|
      run %( /opt/homebrew/bin/rclone sync ~/#{local} #{remote}#{flag}#{filter} )
    end
  end
end

namespace :install do
  desc 'Install files'

  task :app_config do
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
      system %( mackup restore --dry-run && mackup uninstall --dry-run )
    else
      run %( mackup restore --force && mackup uninstall --force )
    end
  end

  task :dotfiles do
    section 'Using Dotbot to symlink dotfiles'

    run %( dotbot -c dotbot.conf.yaml )
  end
end

namespace :uninstall do
  desc 'Uninstall dotfiles'

  # Don't need to uninstall Mackup as we don't use symlinks

  task :dotfiles do
    section 'Uninstall Dotbot and restoring dotfiles'

    run %( python dotbot_uninstall )
  end
end
