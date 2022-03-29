ZSH_PLUGINS_DIR = File.expand_path('~/.local/share/zsh/plugins', __dir__)

namespace :install do
  desc "Install Zsh Plugins"
  task :zsh_plugins do
    section "Installing Zsh Plugins"

    run %( git clone https://github.com/zsh-users/zsh-syntax-highlighting #{ZSH_PLUGINS_DIR}/zsh-syntax-highlighting )
    run %( git clone https://github.com/zsh-users/zsh-autosuggestions #{ZSH_PLUGINS_DIR}/zsh-autosuggestions )
    run %( git clone https://github.com/zsh-users/zsh-completions #{ZSH_PLUGINS_DIR}/zsh-completions )
  end

  desc "Install Zsh"
  task :zsh do
    section "Installing Zsh"
  
    unless ENV['SHELL'] == "/opt/homebrew/bin/zsh"
      run %( sudo dscl . -delete /Users/#{ENV['USER']} UserShell )
      run %( sudo dscl . -create /Users/#{ENV['USER']} UserShell /opt/homebrew/bin/zsh )
    else
      puts "~> Zsh is already installed."
    end
  end

end

namespace :update do
  desc "Update Zsh Plugins"
  task :zsh_plugins do
    section "Updating Zsh Plugins"

    run %( cd #{ZSH_PLUGINS_DIR} && ls | xargs -I{} git -C {} pull )
  end
end
