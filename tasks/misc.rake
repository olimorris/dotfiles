PIP_FILE = File.expand_path('../../brew/pip.txt', __FILE__)
NPM_FILE = File.expand_path('../../brew/npm.txt', __FILE__)
FONT_PATH = File.expand_path('/Users/Oli/Tresors/Oli\'s Documents/ff/Fonts')

namespace :backup do
  desc "Backup PIP files"
  task :pip do
    section "Backing up PIP files"

    run %( pip3 freeze \> #{PIP_FILE} )
  end

  desc "Backup NPM files"
  task :npm do
    section "Backing up NPM files"

    run %( npm -g upgrade )
    run %( npm list --global --parseable --depth=0 | sed '1d' | awk '\{gsub\(/\\/.*\\//,"",$1\); print\}' \> #{NPM_FILE} )
  end
end

namespace :install do

  desc "Install fonts"
  task :fonts do
    section "Installing fonts"

    if ! testing?
      Dir.foreach(FONT_PATH) do |font|
        next if font == '.' or font == '..' or font == '.DS_Store'
        escaped_path = FONT_PATH.gsub("'"){"\\'"}
        escaped_path = escaped_path.gsub(" "){"\\ "}
        font = font.gsub(" "){"\\ "}
        run %( cp #{escaped_path}/#{font} ~/Library/Fonts )
      end
    end
  end

  desc "Install XCode"
  task :xcode do
    section "Installing XCode"

    run %( xcode-select --install )
  end

  desc "Install macOS Configurations"
  task :macos do
    section "Installing macOS Configurations"

    run %( sh ./misc/macos )
  end

  desc "Install Python"
  task :python do
    section "Installing Python"

    if ! testing?
      run %( asdf plugin add python )
      run %( asdf install python 2.7.18 )
      run %( asdf install python 3.9.2 )
      run %( asdf global python 3.9.2 2.7.18 )
      run %( ln -s ~/.asdf/installs/python/3.9.2 ~/.asdf/installs/python/global )
    end
  end

  # desc "Install Neovim Nightly"
  # task :neovim do
  #   section "Installing Neovim Nightly"

  #   if ! testing?
  #     run %( git clone https://github.com/neovim/neovim.git $HOME/.neovim )
  #     run %( \(cd $HOME/.neovim && make CMAKE_BUILD_TYPE=Release\) )
  #     run %( chmod +x $HOME/.dotfiles/bin/nvim )
  #   end
  # end

  desc "Install PIP files"
  task :pip do
    section "Installing PIP files"

    run %( pip3 install -r #{PIP_FILE} )
  end

  desc "Install NPM files"
  task :npm do
    section "Installing NPM files"

    run %( xargs npm install --global \< #{NPM_FILE} )
  end

  desc "Install NixOS"
  task :nix do
    section "Installing NixOS"

    run %( sh <\(curl -L https://nixos.org/nix/install\) --darwin-use-unencrypted-nix-store-volume )
  end

  desc "Install Lua Lsp"
  task :lua do
    section "Installing Lua Language Server"

    run %( git clone https://github.com/sumneko/lua-language-server ~/.config/lua-language-server )
    run %( \(cd ~/.config/lua-language-server && git submodule update --init --recursive && cd 3rd/luamake && ninja -f ninja/macos.ninja && cd ../.. && ./3rd/luamake/luamake rebuild \) )

  end

  desc "Install true color support for Tmux and Alacritty"
  task :tmux_color do
    section "Installing Tmux and Alacritty colors"

    run %( curl -LO https://invisible-island.net/datafiles/current/terminfo.src.gz && gunzip terminfo.src.gz )
    run %( /usr/bin/tic -xe tmux-256color terminfo.src )
    run %( /usr/bin/tic -xe alacritty-direct,tmux-256color terminfo.src )
    run %( rm terminfo.src )
  end

  task :tmux do
    section "Installing Tmux plugins"

    run %( rm -rf ~/.tmux/plugins )
    run %( git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm )
    run %( ~/.tmux/plugins/tpm/bin/install_plugins )
  end

  task :launchagents do
    section "Installing Launch Agents"

    run %( launchctl load -w ~/Library/LaunchAgents/oli.dark-mode-notify.plist )
  end
end

namespace :update do
  # desc "Update Neovim Nightly"
  # task :neovim do
  #   section "Updating Neovim Nightly"

  #   if ! testing?
  #     run %( \(cd $HOME/.neovim && git pull && make distclean && make CMAKE_BUILD_TYPE=Release\) )
  #   end
  # end

  desc "Update PIP files"
  task :pip do
    section "Updating PIP files"

    run %( pip3 install --upgrade pip )
    run %( pip3 freeze \> #{PIP_FILE} )
    find_replace(PIP_FILE, '==', '>=')
    run %( pip3 install -r #{PIP_FILE} --upgrade )
  end

  desc "Update NPM packages"
  task :npm do
    section "Updating NPM"

    run %( npm install -g npm && npm update -g )
  end

  desc "Update Lua Lsp"
  task :lua do
    section "Updating Lua Language Server"

    run %( \(cd ~/.config/lua-language-server && git pull && git submodule update --init --recursive && cd 3rd/luamake && ninja -f ninja/macos.ninja && cd ../.. && ./3rd/luamake/luamake rebuild \) )

  end

  desc "Update Tmux plugins"
  task :tmux do
    section "Updating Tmux plugins"

    run %( ~/.tmux/plugins/tpm/bin/update_plugins all )
  end
end