namespace :backup do
  desc 'Backup app config'
  task :app_config do
    section 'Backing up app configs'

    Mackup.backup
  end
end

namespace :install do
  desc 'Install files'

  task :app_config do
    section 'Restoring app configs'

    # run %( rm -rf /usr/local/bin/obs ) if File.exist?('/usr/local/bin/obs')
    # run %( ln -s #{File.expand_path('~/.dotfiles/bin/recording')} /usr/local/bin/recording )
    Mackup.restore
  end

  task :dotbot do
    section 'Using Dotbot to symlink dotfiles'

    run %( dotbot -c dotbot.conf.yaml )
  end

  desc 'Symlink each agent skill into ~/.claude/skills'
  task :skills do
    section 'Symlinking agent skills for Claude'

    source = File.expand_path('../.config/agents/skills', __dir__)
    target = File.expand_path('~/.claude/skills')
    run %( mkdir -p "#{target}" )

    # Removed or renamed skills leave links that Claude would still list
    Dir.glob("#{target}/*").select { |path| File.symlink?(path) && !File.exist?(path) }.each do |path|
      run %( rm "#{path}" )
    end

    Dir.glob("#{source}/*/").each do |dir|
      name = File.basename(dir)
      link = File.join(target, name)

      # ln -sfn onto a real directory would nest the link inside it instead of replacing it
      if File.directory?(link) && !File.symlink?(link)
        puts "~> Skipped #{name}: #{link} is a real directory"
        next
      end

      run %( ln -sfn "#{File.join(source, name)}" "#{link}" )
    end
  end
end

namespace :uninstall do
  desc 'Uninstall dotfiles'

  task :dotbot do
    section 'Uninstall Dotbot and restoring dotfiles'

    run %( python dotbot_uninstall )
  end
end
