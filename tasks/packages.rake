BREW_TAPS_FILE = File.expand_path('../misc/packages/brew_taps.txt', __dir__).gsub(/ /, '\ ')
BREW_PACKAGES_FILE = File.expand_path('../misc/packages/brew_packages.txt', __dir__).gsub(/ /, '\ ')
BREW_CASK_PACKAGES_FILE = File.expand_path('../misc/packages/brew_cask.txt', __dir__).gsub(/ /, '\ ')
CARGO_FILE = File.expand_path('../misc/packages/rust_cargo.txt', __dir__).gsub(/ /, '\ ')
GEMS_FILE = File.expand_path('../misc/packages/ruby_gems.txt', __dir__).gsub(/ /, '\ ')
MAS_FILE = File.expand_path('../misc/packages/app_store.txt', __dir__).gsub(/ /, '\ ')
NPM_FILE = File.expand_path('../misc/packages/npm_packages.txt', __dir__).gsub(/ /, '\ ')
PIP_FILE = File.expand_path('../misc/packages/python_pip.txt', __dir__).gsub(/ /, '\ ')

# HEAD_ONLY_FORMULAS = %w( neovim )
HEAD_ONLY_FORMULAS = ''

namespace :backup do
  desc 'Backup Homebrew'
  task :brew do
    section 'Backing up Homebrew'

    run %( brew leaves > #{BREW_PACKAGES_FILE} )
    run %( brew list --cask > #{BREW_CASK_PACKAGES_FILE} )
    run %( brew tap > #{BREW_TAPS_FILE} )
  end

  desc 'Backup App Store'
  task :app_store do
    section 'Backing up App Store apps'

    run %( mas list \> #{MAS_FILE} )
  end

  desc 'Backup Ruby Gems'
  task :gems do
    section 'Backing up Ruby Gems'

    run %( gem list --no-versions | sed '1d' | awk '\{gsub\(/\\/.*\\//,"",$1\); print\}' \> #{GEMS_FILE} )
  end

  desc 'Backup NPM files'
  task :npm do
    section 'Backing up NPM files'

    run %( npm -g upgrade )

    # Check if npm command succeeds before redirecting
    if system('npm list --global --parseable --depth=0 >/dev/null 2>&1')
      run %( npm list --global --parseable --depth=0 | sed '1d' | awk '\{gsub\(/\\/.*\\//,"",$1\); print\}' \> #{NPM_FILE} )
    else
      puts 'Warning: npm list command failed, skipping backup'
    end
  end

  desc 'Backup PIP files'
  task :pip do
    section 'Backing up PIP files'

    run %( pip3 freeze \> #{PIP_FILE} )
  end
end

namespace :install do
  desc 'Install XCode'
  task :xcode do
    section 'Installing XCode'

    run %( xcode-select --install )
  end

  desc 'Install Homebrew'
  task :brew do
    section 'Installing Homebrew'

    run %( /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\" )
    run %( echo >> /Users/$(whoami)/.zprofile)
    run %( echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> /Users/$(whoami)/.zprofile)
    run %( eval "$(/opt/homebrew/bin/brew shellenv)" )

    # puts '~> Updating Homebrew directory permissions'
    # run %( sudo chown -R $(whoami) /usr/local/ )
    # run %( sudo chown -R $(whoami) /opt/homebrew/ )

    puts '~> Installing Homebrew taps'
    brew_taps.each do |tap|
      run %( brew tap #{tap} )
    end

    run %( brew analytics off )
  end

  desc 'Install Homebrew Packages'
  task :brew_packages do
    section 'Installing Homebrew Packages'

    brew_packages.each do |package|
      if HEAD_ONLY_FORMULAS.include?(package)
        run %( brew install --HEAD #{package} )
      else
        run %( brew install #{package} )
      end
    end
  end

  desc 'Install Homebrew Cask Packages'
  task :brew_cask_packages do
    section 'Installing Homebrew Cask Packages'

    brew_cask_packages.each do |package|
      run %( brew install --force --appdir="/Applications" --fontdir="/Library/Fonts" #{package} )
    end
  end

  desc 'Clean up Homebrew'
  task :brew_clean_up do
    section 'Cleaning up Homebrew'

    run %( brew cleanup )
  end

  desc 'Install App Store apps'
  task :app_store do
    section 'Installing App Store apps'

    app_store_apps.each do |app|
      run %( mas install #{app} )
    end
  end

  desc 'Install Rust'
  task :rust do
    section 'Installing Rust'

    run %(curl https://sh.rustup.rs -sSf | sh)
  end

  desc 'Install Rust Cargo'
  task :cargo do
    section 'Installing Rust Cargo'

    cargo_apps.each do |app|
      run %( cargo install #{app} )
    end
  end

  desc 'Install Ruby Gems'
  task :gems do
    section 'Installing Ruby Gems'

    run %( xargs gem install \< #{GEMS_FILE} )
  end

  desc 'Install NPM files'
  task :npm do
    section 'Installing NPM files'

    run %( xargs npm install --global \< #{NPM_FILE} )
  end

  desc 'Install PIP files'
  task :pip do
    section 'Installing PIP files'

    run %( pip3 install -r #{PIP_FILE} )
  end

  desc 'Install Fish plugins'
  task :fish do
    section 'Installing Fish plugins'

    run %( curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher )
    run %( fish -c "fisher update" )
  end
end

namespace :update do
  desc 'Update Homebrew'
  task :brew do
    section 'Updating Homebrew'

    run %( brew update )
    run %( brew upgrade )
  end

  desc 'Update Fish'
  task :fish do
    section 'Updating Fish plugins'

    run %( fish -c "fisher update" )
  end

  desc 'Update Ruby Gems'
  task :gems do
    section 'Updating Ruby Gems'

    run %( gem update --system && gem update )
  end

  desc 'Update NPM packages'
  task :npm do
    section 'Updating NPM'

    run %( npm install -g npm && npm update -g )
  end

  desc 'Update PIP files'
  task :pip do
    section 'Updating PIP files'

    begin
      run %( pip3 install --upgrade pip )
      run %( pip3 freeze \> #{PIP_FILE} )
      find_replace(PIP_FILE, '==', '>=')
      run %( pip3 install -r #{PIP_FILE} --upgrade )
    rescue StandardError
      puts 'PIP update failed'
    end
  end
end

def brew_taps
  File.readlines(BREW_TAPS_FILE).map(&:strip)
end

def brew_packages
  File.readlines(BREW_PACKAGES_FILE).map(&:strip)
end

def brew_cask_packages
  File.readlines(BREW_CASK_PACKAGES_FILE).map(&:strip)
end

def app_store_apps
  File.readlines(MAS_FILE).map(&:split).map(&:first)
end

def cargo_apps
  File.readlines(CARGO_FILE).map(&:split).map(&:first)
end
