namespace :work do
  namespace :restore do
    desc 'Restore files'
    task :files, [:progress] do |_t, args|
      run %( /bin/date -u )

      dirs = {
        # '.dotfiles' => "#{ENV['STORAGE_FOLDER']}:dotfiles",
        'Code' => "#{ENV['STORAGE_ENCRYPTED_FOLDER']}:Code"
      }

      flag = ' -P' if args[:progress]
      filter = ' --filter-from ~/.config/rclone/filter_list.txt'

      dirs.each do |local, remote|
        run %( /opt/homebrew/bin/rclone copy #{remote}#{flag} ~/#{local}#{filter} )
      end
    end
  end

  namespace :backup do
    desc 'Backup files'
    task :files, [:progress] do |_t, args|
      run %( /bin/date -u )

      dirs = {
        # '.dotfiles' => "#{ENV['STORAGE_FOLDER']}:dotfiles",
        'Code' => "#{ENV['STORAGE_ENCRYPTED_FOLDER']}:Code"
      }

      flag = ' -P' if args[:progress]
      filter = ' --filter-from ~/.config/rclone/filter_list.txt'

      dirs.each do |local, remote|
        run %( /opt/homebrew/bin/rclone copy ~/#{local} #{remote}#{flag}#{filter} )
      end
    end
  end
end
