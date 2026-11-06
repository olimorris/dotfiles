namespace :backup do
  task :app_config do
    section 'Backing up app configs'

    Mackup.backup
  end
end

namespace :install do
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
end

namespace :uninstall do
  task :dotbot do
    section 'Uninstall Dotbot and restoring dotfiles'

    run %( python dotbot_uninstall )
  end
end
