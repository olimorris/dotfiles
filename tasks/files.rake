namespace :backup do
  desc 'Backup app config'
  task :app_config do
    section 'Using Mackup to backup app configs'

    if ENV['DRY_RUN']
      puts "~> Chill! It's a dry run"
      system %( mackup backup --dry-run && mackup restore --dry-run )
    else
      run %( mackup backup --force && mackup restore --force )
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

      flag = args[:progress] ? ' -P -v' : ''
      filter = ' --filter-from ~/.config/rclone/base_filter.txt'
      speed_flags = ' --fast-list --use-mmap --transfers=8 --check-first'

      dirs.each do |local, remote|
        run %( /opt/homebrew/bin/rclone sync ~/#{local} #{remote}#{filter}#{speed_flags}#{flag} )
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
      system %( mackup restore --dry-run )
    else
      # run %( rm -rf /usr/local/bin/obs ) if File.exist?('/usr/local/bin/obs')
      # run %( ln -s #{File.expand_path('~/.dotfiles/bin/recording')} /usr/local/bin/recording )
      run %( mackup restore --force )
    end
  end

  task :dotbot do
    section 'Using Dotbot to symlink dotfiles'

    run %( dotbot -c dotbot.conf.yaml )
  end
end

namespace :uninstall do
  desc 'Uninstall dotfiles'

  # Don't need to uninstall Mackup as we don't use symlinks

  task :dotbot do
    section 'Uninstall Dotbot and restoring dotfiles'

    run %( python dotbot_uninstall )
  end
end
