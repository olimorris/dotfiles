require "fileutils"
require "json"

PACKAGES_FOLDER = File.expand_path("../misc/packages", __dir__)
BREW_TAPS_FILE = File.expand_path("../misc/packages/brew_taps.txt", __dir__).gsub(/ /, "\\ ")
BREW_PACKAGES_COMMON_FILE = File.expand_path("../misc/packages/brew_packages_common.txt", __dir__).gsub(/ /, "\\ ")
BREW_PACKAGES_PERSONAL_FILE = File.expand_path("../misc/packages/brew_packages_personal.txt", __dir__).gsub(/ /, "\\ ")
BREW_PACKAGES_WORK_FILE = File.expand_path("../misc/packages/brew_packages_work.txt", __dir__).gsub(/ /, "\\ ")
BREW_CASK_COMMON_FILE = File.expand_path("../misc/packages/brew_cask_common.txt", __dir__).gsub(/ /, "\\ ")
BREW_CASK_PERSONAL_FILE = File.expand_path("../misc/packages/brew_cask_personal.txt", __dir__).gsub(/ /, "\\ ")
BREW_CASK_WORK_FILE = File.expand_path("../misc/packages/brew_cask_work.txt", __dir__).gsub(/ /, "\\ ")
CARGO_FILE = File.expand_path("../misc/packages/rust_cargo.txt", __dir__).gsub(/ /, "\\ ")
GEMS_FILE = File.expand_path("../misc/packages/ruby_gems.txt", __dir__).gsub(/ /, "\\ ")
MAS_COMMON_FILE = File.expand_path("../misc/packages/app_store_common.txt", __dir__).gsub(/ /, "\\ ")
MAS_PERSONAL_FILE = File.expand_path("../misc/packages/app_store_personal.txt", __dir__).gsub(/ /, "\\ ")
MAS_WORK_FILE = File.expand_path("../misc/packages/app_store_work.txt", __dir__).gsub(/ /, "\\ ")
NPM_FILE = File.expand_path("../misc/packages/npm_packages.txt", __dir__).gsub(/ /, "\\ ")
PIP_FILE = File.expand_path("../misc/packages/python_pip.txt", __dir__).gsub(/ /, "\\ ")

# HEAD_ONLY_FORMULAS = %w( neovim )
HEAD_ONLY_FORMULAS = ""

namespace(:backup) do
  desc("Backup Homebrew")
  task(:brew) do
    section("Backing up Homebrew")
    ensure_packages_folder

    backup_brew_list("brew leaves", BREW_PACKAGES_COMMON_FILE, brew_packages_machine_file)
    backup_brew_list("brew list --cask", BREW_CASK_COMMON_FILE, brew_cask_machine_file)
    run(" brew tap > #{BREW_TAPS_FILE} ")
  end

  desc("Backup App Store")
  task(:app_store) do
    section("Backing up App Store apps")
    ensure_packages_folder

    backup_mas_list(MAS_COMMON_FILE, mas_machine_file)
  end

  desc("Backup Ruby Gems")
  task(:gems) do
    section("Backing up Ruby Gems")
    ensure_packages_folder

    run(" gem list --no-versions | sed '1d' | awk '\{gsub(/\\/.*\\//,\"\",$1); print\}' \> #{GEMS_FILE} ")
  end

  desc("Backup NPM files")
  task(:npm) do
    section("Backing up NPM files")
    ensure_packages_folder

    # Check if npm command succeeds before redirecting
    if system("npm ls --global --depth=0 --json >/dev/null 2>&1")
      run(" npm ls --global --depth=0 --json > #{NPM_FILE} ")
      run(" npm prefix -g > #{NPM_FILE}.prefix ")
    else
      puts("Warning: npm list command failed, skipping backup")
    end
  end

  desc("Backup PIP files")
  task(:pip) do
    section("Backing up PIP files")
    ensure_packages_folder

    run(" pip freeze \> #{PIP_FILE} ")
  end
end

namespace(:install) do
  desc("Install XCode")
  task(:xcode) do
    section("Installing XCode")

    run(" xcode-select --install ")
  end

  desc("Install Homebrew")
  task(:brew) do
    section("Installing Homebrew")

    run(" /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\" ", check: true)
    run(" echo >> /Users/$(whoami)/.zprofile")
    run(" echo 'eval \"$(/opt/homebrew/bin/brew shellenv)\"' >> /Users/$(whoami)/.zprofile")

    # puts '~> Updating Homebrew directory permissions'
    # run %( sudo chown -R $(whoami) /usr/local/ )
    # run %( sudo chown -R $(whoami) /opt/homebrew/ )

    puts("~> Installing Homebrew taps")
    brew_taps.each do |tap|
      run(" brew tap #{tap} ")
    end

    run(" brew analytics off ")
  end

  desc("Install Homebrew Packages")
  task(:brew_packages) do
    section("Installing Homebrew Packages")

    brew_packages.each do |package|
      if HEAD_ONLY_FORMULAS.include?(package)
        run(" brew install --HEAD #{package} ")
      else
        run(" brew install #{package} ")
      end
    end
  end

  desc("Install Homebrew Cask Packages")
  task(:brew_cask_packages) do
    section("Installing Homebrew Cask Packages")

    brew_cask_packages.each do |package|
      run(" brew install --force --appdir=\"/Applications\" --fontdir=\"/Library/Fonts\" #{package} ")
    end
  end

  desc("Clean up Homebrew")
  task(:brew_clean_up) do
    section("Cleaning up Homebrew")

    run(" brew cleanup ")
  end

  desc("Install App Store apps")
  task(:app_store) do
    section("Installing App Store apps")

    app_store_apps.each do |app|
      run(" mas install #{app} ")
    end
  end

  desc("Install Rust")
  task(:rust) do
    section("Installing Rust")

    # -y: rustup's installer is interactive by default and blocks the whole run
    # waiting on a "proceed with installation" answer that nobody is there to give.
    run(" curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y ")
  end

  desc("Install Rust Cargo")
  task(:cargo) do
    section("Installing Rust Cargo")

    cargo_apps.each do |app|
      run(" cargo install #{app} ")
    end
  end

  desc("Install Ruby Gems")
  task(:gems) do
    section("Installing Ruby Gems")

    next unless package_file?(GEMS_FILE)

    run(" xargs gem install \< #{GEMS_FILE} ")
  end

  desc("Install NPM files")
  task(:npm) do
    section("Installing NPM files")

    unless File.exist?(NPM_FILE)
      puts("No npm backup file found at #{NPM_FILE}")
      next
    end

    begin
      data = JSON.parse(File.read(NPM_FILE))
      deps = data.fetch("dependencies", {})
      if deps.empty?
        puts("No global packages listed in npm backup")
      else
        deps.each do |name, info|
          # Skip npm itself to avoid changing the running npm while installing
          next if name == "npm"

          version = info && info["version"] ? "@#{info["version"]}" : ""
          run(" npm install -g #{name}#{version} ")
        end
      end

    rescue StandardError => e
      puts("Failed to parse #{NPM_FILE}: #{e}")
    end
  end

  desc("Install PIP files")
  task(:pip) do
    section("Installing PIP files")

    next unless package_file?(PIP_FILE)

    run(" pip install -r #{PIP_FILE} ")
  end

  desc("Install Fish plugins and make Fish the login shell")
  task(:fish) do
    section("Installing Fish plugins")

    # The whole pipeline is fish syntax, and `run` shells out via /bin/sh - so it has
    # to go through `fish -c`. Previously sh was handed `... | source` directly and
    # fisher never installed.
    run(
      " fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher' "
    )
    run(" fish -c \"fisher update\" ")

    Rake::Task["install:default_shell"].invoke
  end

  desc("Make Fish the login shell")
  task(:default_shell) do
    section("Setting Fish as the login shell")

    fish = "/opt/homebrew/bin/fish"
    unless File.executable?(fish)
      puts("~> #{fish} not found, skipping")
      next
    end

    # chsh refuses any shell that isn't listed in /etc/shells, so register it first.
    if File.readlines("/etc/shells").map(&:strip).include?(fish)
      puts("~> Already in /etc/shells")
    else
      run(" echo #{fish} | sudo tee -a /etc/shells ")
    end

    user = `whoami`.strip
    if `dscl . -read /Users/#{user} UserShell`.strip.end_with?(fish)
      puts("~> Already the login shell")
    else
      # sudo chsh rather than plain chsh: plain chsh prompts for the account password
      # through PAM, and sudo is usually already primed by this point in the run.
      run(" sudo chsh -s #{fish} #{user} ")
    end
  end
end

namespace(:update) do
  desc("Update Homebrew")
  task(:brew) do
    section("Updating Homebrew")

    run(" brew update ")
    run(" brew upgrade ")
  end

  desc("Update Fish")
  task(:fish) do
    section("Updating Fish plugins")

    run(" fish -c \"fisher update\" ")
  end

  desc("Update Ruby Gems")
  task(:gems) do
    section("Updating Ruby Gems")

    run(" gem update --system && gem update ")
  end

  desc("Update NPM packages")
  task(:npm) do
    section("Updating NPM")

    run(" npm install -g npm && npm update -g ")
  end

  desc("Update PIP files")
  task(:pip) do
    section("Updating PIP files")

    begin
      run(" pip install --upgrade pip ")
      run(" pip install -r #{PIP_FILE} --upgrade ")
    rescue StandardError
      puts("PIP update failed")
    end
  end
end

# misc/packages is rclone-synced rather than committed, so on a fresh clone - or in
# CI, where only a few stubs get written - a list is legitimately absent.
def package_lines(file)
  path = file.gsub("\\ ", " ")
  unless File.exist?(path)
    puts("~> #{File.basename(path)} not found, skipping")
    return []
  end

  File.readlines(path).map(&:strip).reject(&:empty?)
end

def package_file?(file)
  path = file.gsub("\\ ", " ")
  return true if File.exist?(path)

  puts("~> #{File.basename(path)} not found, skipping")
  false
end

def ensure_packages_folder
  FileUtils.mkdir_p(PACKAGES_FOLDER)
end

def brew_taps
  package_lines(BREW_TAPS_FILE)
end

def backup_brew_list(list_cmd, common_file, machine_file)
  common = package_lines(common_file)
  installed = `#{list_cmd}`.lines.map(&:strip).reject(&:empty?)
  unique = installed - common

  puts("~> #{list_cmd} (#{unique.size} unique, #{installed.size - unique.size} already in common)")
  File.write(machine_file.gsub("\\ ", " "), "#{unique.join("\n")}\n") unless ENV["DRY_RUN"]
end

# mas list prints "<id>  <name>  (<version>)", so the same app reads differently on two
# machines whenever a version does. Match on the id alone - comparing whole lines would
# file every version bump as a machine-specific app.
def backup_mas_list(common_file, machine_file)
  common_ids = package_lines(common_file).map { |line| line.split.first }
  installed = `mas list`.lines.map(&:strip).reject(&:empty?)
  unique = installed.reject { |line| common_ids.include?(line.split.first) }

  puts("~> mas list (#{unique.size} unique, #{installed.size - unique.size} already in common)")
  File.write(machine_file.gsub("\\ ", " "), "#{unique.join("\n")}\n") unless ENV["DRY_RUN"]
end

def brew_packages_machine_file
  personal_machine? ? BREW_PACKAGES_PERSONAL_FILE : BREW_PACKAGES_WORK_FILE
end

def brew_cask_machine_file
  personal_machine? ? BREW_CASK_PERSONAL_FILE : BREW_CASK_WORK_FILE
end

def brew_packages
  package_lines(BREW_PACKAGES_COMMON_FILE) + package_lines(brew_packages_machine_file)
end

def brew_cask_packages
  package_lines(BREW_CASK_COMMON_FILE) + package_lines(brew_cask_machine_file)
end

def mas_machine_file
  personal_machine? ? MAS_PERSONAL_FILE : MAS_WORK_FILE
end

def app_store_apps
  (package_lines(MAS_COMMON_FILE) + package_lines(mas_machine_file)).map { |line| line.split.first }
end

def cargo_apps
  package_lines(CARGO_FILE).map { |line| line.split.first }
end
