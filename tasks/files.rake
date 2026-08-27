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
end

namespace :install do
  desc 'Install files'

  # No symlinking here: dotbot already links ~/.mackup and ~/.mackup.cfg, and
  # install:dotbot runs first. This used to `ln -s ~/.dotfiles/.mackup.cfg`, a path
  # that has never existed - the real file is .config/mackup/.mackup.cfg - so the
  # branch only ever printed "Already installed" and did nothing.
  task :app_config do
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
