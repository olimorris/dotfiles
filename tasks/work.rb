namespace :work do
  namespace :restore do
    desc 'Restore files'
    task :files, [:progress] do |_t, args|
      run %( /bin/date -u )

      dirs_with_filters = {
        '.dotfiles' => { remote: "#{ENV['STORAGE_ENCRYPTED_FOLDER']}:dotfiles", filter: 'dotfiles_filter.txt' },
        'Code' => { remote: "#{ENV['STORAGE_ENCRYPTED_FOLDER']}:Code", filter: 'code_filter.txt' }
      }

      flag = args[:progress] ? ' -P -v' : ''
      base_filter = ' --filter-from ~/.config/rclone/base_filter.txt'
      speed_flags = ' --fast-list --use-mmap --transfers=16 --checkers=16 --size-only --no-traverse'

      dirs_with_filters.each do |local, config|
        specific_filter = " --filter-from ~/.config/rclone/#{config[:filter]}"
        run %( /opt/homebrew/bin/rclone sync #{config[:remote]} ~/#{local}#{base_filter}#{specific_filter}#{speed_flags}#{flag} )
      end
    end
  end

  namespace :backup do
    desc 'Backup files'
    task :files, [:progress] do |_t, args|
      run %( /bin/date -u )

      dirs_with_filters = {
        '.dotfiles' => { remote: "#{ENV['STORAGE_ENCRYPTED_FOLDER']}:dotfiles", filter: 'dotfiles_filter.txt' },
        'Code' => { remote: "#{ENV['STORAGE_ENCRYPTED_FOLDER']}:Code", filter: 'code_filter.txt' }
      }

      flag = args[:progress] ? ' -P -v' : ''
      base_filter = ' --filter-from ~/.config/rclone/base_filter.txt'
      speed_flags = ' --fast-list --use-mmap --transfers=16 --checkers=16 --size-only --no-traverse'

      dirs_with_filters.each do |local, config|
        specific_filter = " --filter-from ~/.config/rclone/#{config[:filter]}"
        run %( /opt/homebrew/bin/rclone sync ~/#{local} #{config[:remote]}#{base_filter}#{specific_filter}#{speed_flags}#{flag} )
      end
    end
  end
end
