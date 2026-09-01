# Inspiration taken from: https://github.com/kevinjalbert/dotfiles/
# This Rakefile should not be run with sudo, it will use sudo where necessary.
# To perform tasks in a 'dry run' state append the following to your command:
# DRY_RUN=true
DOTS_FOLDER = ".dotfiles"
DIRECTORY_NAME = File.dirname(__dir__)
# mas.rake brew.rake
SKIP_TESTS_FOR = %w[].freeze

# Put the dirs these tasks install into on PATH for this process. `run` shells out via
# `system`, so an `eval "$(brew shellenv)"` inside a task only ever changes a subshell
# that then exits - on a fresh Mac every later `brew` call would still be off-PATH.
# Also covers launchd, which runs the backup agent with a minimal PATH.
#
# The last three are here for the same reason. The fish config adds them, but rake gets
# run from whatever shell is current, which on a fresh Mac is zsh - so without them
# install:cargo can't find cargo, and install:neovim can't find nvimv or the nvim shim
# nvimv writes into ~/.local/bin.
EXTRA_PATHS = [
  "/opt/homebrew/bin",
  "/opt/homebrew/sbin",
  File.expand_path("bin", __dir__),
  File.expand_path("~/.local/bin"),
  File.expand_path("~/.cargo/bin")
].freeze

missing_paths = EXTRA_PATHS - ENV["PATH"].to_s.split(File::PATH_SEPARATOR)
ENV["PATH"] = (missing_paths + [ENV["PATH"]]).join(File::PATH_SEPARATOR) unless missing_paths.empty?

# Load .env into this process. The shell normally does this from ~/.env, but that's a
# dotbot symlink that doesn't exist until install:dotbot runs - and rake init needs
# STORAGE_ENCRYPTED_FOLDER before then, to know which remote to restore from. Anything
# already set wins, so a configured shell still takes precedence.
env_file = File.expand_path(".config/env/.env", __dir__)
if File.exist?(env_file)
  File.readlines(env_file).each do |line|
    line = line.strip
    next if line.empty? || line.start_with?("#")

    key, value = line.split("=", 2)
    ENV[key] ||= value if value
  end
end

Dir.glob("./tasks/**/*").map { |file| load(file) }

task(default: [:backup])

desc("Backup Everything")
task(:backup) do
  section("Backing up")

  # Packages
  Rake::Task["backup:brew"].invoke
  Rake::Task["backup:app_store"].invoke
  Rake::Task["backup:gems"].invoke
  Rake::Task["backup:npm"].invoke
  Rake::Task["backup:pip"].invoke

  # Files. cloud:push is the only file sync path - it does mackup, then rclone.
  Rake::Task["cloud:push"].invoke
end

desc("Install Everything")
task(:install) do
  section("Installing")

  Rake::Task["tests:setup"].invoke if testing?

  # Homebrew first: everything below is either a brew package or needs one.
  # install:xcode is deliberately not here. The Homebrew installer installs the
  # Command Line Tools itself, and `xcode-select --install` exits non-zero once
  # they're present, so it only ever added noise to the failed-commands report.
  Rake::Task["install:brew"].invoke
  Rake::Task["install:brew_packages"].invoke
  Rake::Task["install:brew_cask_packages"].invoke
  Rake::Task["install:brew_clean_up"].invoke
  Rake::Task["install:app_store"].invoke unless testing?

  # Files next, not last. dotbot puts ~/.config/mise, ~/.config/fish and ~/.env in
  # place and chmod makes ~/.dotfiles/bin runnable - every step below needs one of
  # those. These used to sit near the end, so `rake install` on its own ran mise and
  # fish against config that did not exist yet, while `rake init` got the right order
  # by accident because cloud:pull had already run them.
  Rake::Task["install:dotbot"].invoke
  Rake::Task["install:app_config"].invoke
  Rake::Task["install:chmod"].invoke

  # Runtimes, then the packages that need them
  Rake::Task["install:servers"].invoke
  Rake::Task["install:rust"].invoke unless testing?
  Rake::Task["install:cargo"].invoke unless testing?
  Rake::Task["install:gems"].invoke unless testing?
  Rake::Task["install:npm"].invoke unless testing?
  Rake::Task["install:pip"].invoke unless testing?

  # Shell
  Rake::Task["install:fish"].invoke unless testing?

  # System
  Rake::Task["install:fonts"].invoke
  Rake::Task["install:hammerspoon"].invoke
  Rake::Task["install:launch_agents"].invoke

  # Apps
  Rake::Task["install:vim"].invoke
  Rake::Task["install:neovim"].invoke
  Rake::Task["install:herdr"].invoke unless testing?

  # Dotbot runs a second time on purpose. Two of its links - the ghostty and opencode
  # theme directories - point into ~/.cache/nvim/onedarkpro_dotfiles/extras, which
  # nothing creates until install:neovim runs OneDarkProExtras. On the first pass those
  # two have no source, so dotbot skips them and exits 1 (it still makes every other
  # link). By this point the cache exists, so this pass picks up the stragglers.
  #
  # reenable is required: rake runs a task at most once per process, so a plain second
  # invoke would silently do nothing.
  Rake::Task["install:dotbot"].reenable
  Rake::Task["install:dotbot"].invoke

  Rake::Task["install:macos"].invoke
end

desc("Update Everything")
task(:update) do
  section("Updating")

  Rake::Task["tests:setup"].invoke if testing?

  # Backup packages before brew upgrade (which may update runtimes via mise)
  Rake::Task["backup:gems"].invoke
  Rake::Task["backup:npm"].invoke
  Rake::Task["backup:pip"].invoke

  # Brew upgrade (may install new Python/Node/Ruby versions)
  Rake::Task["update:brew"].invoke
  Rake::Task["update:fish"].invoke

  # Servers
  Rake::Task["update:servers"].invoke

  # Then reinstall and update packages
  Rake::Task["install:gems"].invoke
  Rake::Task["update:gems"].invoke
  Rake::Task["install:npm"].invoke
  Rake::Task["update:npm"].invoke
  Rake::Task["install:pip"].invoke
  Rake::Task["update:pip"].invoke

  # Apps
  Rake::Task["update:vim"].invoke
  Rake::Task["update:neovim"].invoke
end

desc("Install Packages (brew, gems, npm, pip)")
task(:packages) do
  section("Installing Packages")

  Rake::Task["install:brew_packages"].invoke
  Rake::Task["install:brew_cask_packages"].invoke
  Rake::Task["install:brew_clean_up"].invoke
  Rake::Task["install:gems"].invoke
  Rake::Task["install:npm"].invoke
  Rake::Task["install:pip"].invoke
end

desc("Sync Everything")
task(:sync) do
  section("Syncing")

  Rake::Task["update"].invoke
  Rake::Task["backup"].invoke
  Rake::Task["install:brew_clean_up"].invoke
end

desc("Uninstall")
task(:uninstall) do
  section("Uninstalling")

  Rake::Task["uninstall:dotbot"].invoke
end

namespace(:cloud) do
  desc("Cloud -> Mac. GIT=1 to also sync .git folders")
  task(:pull, [:progress]) do |_t, args|
    section("Cloud -> Mac")

    Rake::Task["cloud:restore:files"].invoke(args[:progress])

    # Install packages
    # Rake::Task['install:brew_packages'].invoke
    # Rake::Task['install:brew_cask_packages'].invoke
    # Rake::Task['install:brew_clean_up'].invoke
    # Rake::Task['install:gems'].invoke unless testing?
    # Rake::Task['install:npm'].invoke unless testing?
    # Rake::Task['install:pip'].invoke unless testing?

    # App config
    Rake::Task["install:dotbot"].invoke
    Rake::Task["install:app_config"].invoke
  end

  desc("Mac -> Cloud. GIT=1 to also sync .git folders")
  task(:push, [:progress]) do |_t, args|
    section("Mac -> Cloud")

    Rake::Task["backup:app_config"].invoke
    Rake::Task["cloud:backup:files"].invoke(args[:progress])
  end
end
