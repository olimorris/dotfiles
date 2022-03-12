namespace :install do

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

  desc "Install Oh-My-Zsh"
  task :ohmyzsh do
    section "Installing Oh-My-Zsh"

    unless File.exists?("#{ENV['HOME']}/.local/share/oh-my-zsh/oh-my-zsh.sh")
      run %( git clone http://github.com/robbyrussell/oh-my-zsh ~/.local/share/oh-my-zsh )
      run %( git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.local/share/oh-my-zsh/custom/plugins/zsh-autosuggestions )
      run %( git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.local/share/oh-my-zsh/custom/plugins/zsh-syntax-highlighting )
      run %( chsh -s $(which zsh) )
      puts "~> Don't forget to run `source ~/.zshrc` from a 'new' Zsh shell later."
    else
      puts "~> Oh-My-Zsh is already installed."
    end
  end
end