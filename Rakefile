#     Inspiration taken from: https://github.com/kevinjalbert/dotfiles/
#     Ensure Tresorit is installed and the .dotfiles Tresor is synced to the home
#     folder. Then open the Terminal, cd into .dotfiles and type 'rake'
#
#     This Rakefile should not be ran with sudo, it will use sudo where nessecary.
#     To perform tasks in a 'dry run' state append the following to your command:
#     DRY_RUN=true
DOTS_FOLDER = '.dotfiles'
DIRECTORY_NAME = File.dirname(__dir__)
SKIP_TESTS_FOR = %w[].freeze # mas.rake brew.rake

Dir.glob('./tasks/**/*').map { |file| load file }

task default: [:backup]

desc 'Backup Everything'
task :backup do
  section 'Backing up'
  Rake::Task['backup:brew'].invoke
  Rake::Task['backup:mas'].invoke
  Rake::Task['backup:mackup'].invoke
  Rake::Task['backup:files'].invoke
  Rake::Task['backup:pip'].invoke
  Rake::Task['backup:npm'].invoke
  Rake::Task['backup:gems'].invoke
end

desc 'Install Everything'
task :install do
  section 'Installing'
  Rake::Task['tests:setup'].invoke if testing?
  Rake::Task['install:xcode'].invoke
  Rake::Task['install:brew'].invoke
  Rake::Task['install:brew_packages'].invoke
  Rake::Task['install:brew_cask_packages'].invoke
  Rake::Task['install:mas'].invoke
  Rake::Task['install:brew_clean_up'].invoke
  Rake::Task['install:mackup'].invoke
  Rake::Task['install:dotbot'].invoke
  Rake::Task['install:fonts'].invoke
  Rake::Task['install:macos'].invoke
  Rake::Task['install:servers'].invoke
  # Rake::Task['install:neovim'].invoke
  Rake::Task['install:vim'].invoke
  Rake::Task['install:pip'].invoke
  Rake::Task['install:npm'].invoke
  Rake::Task['install:gems'].invoke
  Rake::Task['install:cargo'].invoke
  Rake::Task['install:fish'].invoke
  # Rake::Task['install:tmux_color'].invoke
  Rake::Task['install:tmux'].invoke
  Rake::Task['install:launchagents'].invoke
  Rake::Task['install:rails'].invoke
  Rake::Task['install:chmod_dots'].invoke
  Rake::Task['install:hammerspoon'].invoke
end

desc 'Update Everything'
task :update do
  section 'Updating'
  Rake::Task['tests:setup'].invoke if testing?
  Rake::Task['update:brew'].invoke
  Rake::Task['update:dotbot'].invoke
  # Rake::Task['update:neovim'].invoke
  # Rake::Task['update:neovim_plugins'].invoke
  Rake::Task['update:vim_plugins'].invoke
  Rake::Task['update:rust'].invoke
  Rake::Task['update:cargo'].invoke
  Rake::Task['update:pip'].invoke
  Rake::Task['update:npm'].invoke
  Rake::Task['update:gems'].invoke
  Rake::Task['update:fish'].invoke
  Rake::Task['update:tmux'].invoke
  Rake::Task['update:rails'].invoke
  Rake::Task['update:servers'].invoke
end

desc 'Sync Everything'
task :sync do
  section '!! Syncing !!'
  Rake::Task['update'].invoke
  Rake::Task['backup'].invoke
  Rake::Task['install:brew_clean_up'].invoke
end
