# Inspiration taken from: https://github.com/kevinjalbert/dotfiles/
# This Rakefile should not be run with sudo, it will use sudo where necessary.
# To perform tasks in a 'dry run' state append the following to your command:
# DRY_RUN=true
DOTS_FOLDER = '.dotfiles'
DIRECTORY_NAME = File.dirname(__dir__)
SKIP_TESTS_FOR = %w[].freeze # mas.rake brew.rake

Dir.glob('./tasks/**/*').map { |file| load file }

task default: [:backup]

desc 'Backup Everything'
task :backup do
  section 'Backing up'

  # Packages
  Rake::Task['backup:brew'].invoke
  Rake::Task['backup:app_store'].invoke
  Rake::Task['backup:gems'].invoke
  Rake::Task['backup:npm'].invoke
  Rake::Task['backup:pip'].invoke

  # Files
  Rake::Task['backup:app_config'].invoke
  Rake::Task['backup:files'].invoke
end

desc 'Install Everything'
task :install do
  section 'Installing'

  Rake::Task['tests:setup'].invoke if testing?

  # Packages
  Rake::Task['install:xcode'].invoke
  Rake::Task['install:brew'].invoke
  Rake::Task['install:brew_packages'].invoke
  Rake::Task['install:brew_cask_packages'].invoke
  Rake::Task['install:brew_clean_up'].invoke
  Rake::Task['install:app_store'].invoke unless testing?

  # Files
  Rake::Task['install:app_config'].invoke
  Rake::Task['install:dotfiles'].invoke

  # System
  Rake::Task['install:chmod'].invoke
  Rake::Task['install:fish'].invoke
  Rake::Task['install:fonts'].invoke
  Rake::Task['install:hammerspoon'].invoke
  Rake::Task['install:launch_agents'].invoke
  Rake::Task['install:macos'].invoke
  Rake::Task['install:servers'].invoke

  # Packages
  Rake::Task['install:gems'].invoke
  Rake::Task['install:npm'].invoke
  Rake::Task['install:pip'].invoke
  Rake::Task['install:tmux'].invoke

  # Apps
  Rake::Task['install:neovim'].invoke
  Rake::Task['install:rails'].invoke
  Rake::Task['install:vim'].invoke
end

desc 'Update Everything'
task :update do
  section 'Updating'

  Rake::Task['tests:setup'].invoke if testing?

  # Packages
  Rake::Task['update:brew'].invoke
  Rake::Task['update:fish'].invoke
  Rake::Task['update:gems'].invoke
  Rake::Task['update:npm'].invoke
  Rake::Task['update:pip'].invoke
  Rake::Task['update:tmux'].invoke

  # Files
  Rake::Task['update:dotfiles'].invoke

  # System
  Rake::Task['update:servers'].invoke

  # Apps
  Rake::Task['update:neovim'].invoke
  Rake::Task['update:rails'].invoke
  Rake::Task['update:vim'].invoke
end

desc 'Sync Everything'
task :sync do
  section 'Syncing'

  Rake::Task['update'].invoke
  Rake::Task['backup'].invoke
  Rake::Task['install:brew_clean_up'].invoke
end

desc 'Uninstall'
task :uninstall do
  section 'Uninstalling'

  Rake::Task['uninstall:dotfiles'].invoke
end
