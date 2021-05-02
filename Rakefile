=begin
    Inspiration taken from: https://github.com/kevinjalbert/dotfiles/
    Ensure Tresorit is installed and the .dotfiles Tresor is synced to the home
    folder. Then open the Terminal, cd into .dotfiles and type 'rake'

    This Rakefile should not be ran with sudo, it will use sudo where nessecary.
    To perform tasks in a 'dry run' state append the following to your command:
    DRY_RUN=true
=end
DOTS_FOLDER = '.dotfiles'
DIRECTORY_NAME = File.dirname(__dir__)
SKIP_TESTS_FOR = %w( ) # mas.rake brew.rake

Dir.glob('./tasks/**/*').map { |file| load file }

task :default => [:backup]

desc "Backup Everything"
task :backup do
  Rake::Task['backup:brew'].invoke
  Rake::Task['backup:mas'].invoke
  Rake::Task['backup:mackup'].invoke
  Rake::Task['backup:pip'].invoke
  Rake::Task['backup:npm'].invoke
end

desc "Install Everything"
task :install do
  if testing?
    Rake::Task['setup:tests'].invoke
  end
  Rake::Task['install:brew'].invoke
  Rake::Task['install:brew_cask_packages'].invoke
  Rake::Task['install:brew_packages'].invoke
  Rake::Task['install:mas'].invoke
  Rake::Task['install:brew_clean_up'].invoke
  Rake::Task['install:mackup'].invoke
  Rake::Task['restore:mackup'].invoke
  Rake::Task['install:zsh'].invoke
  Rake::Task['install:ohmyzsh'].invoke
  Rake::Task['install:fonts'].invoke
  Rake::Task['install:xcode'].invoke
  Rake::Task['install:macos'].invoke
  Rake::Task['install:python'].invoke
  # Rake::Task['install:neovim'].invoke
  Rake::Task['install:pip'].invoke
  Rake::Task['install:nix'].invoke
  Rake::Task['install:npm'].invoke
  Rake::Task['install:lua'].invoke
  Rake::Task['install:tmux_color'].invoke
  Rake::Task['install:tmux'].invoke
  Rake::Task['install:launchagents'].invoke
end

desc "Update Everything"
task :update do
  Rake::Task['update:brew'].invoke
  Rake::Task['update:pip'].invoke
  # Rake::Task['update:neovim'].invoke
  Rake::Task['update:lua'].invoke
  Rake::Task['update:npm'].invoke
  Rake::Task['update:tmux'].invoke
end

desc "Sync Everything"
task :sync do
  Rake::Task['update'].invoke
  Rake::Task['backup'].invoke
  Rake::Task['install:brew_clean_up'].invoke
end