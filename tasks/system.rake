FONT_PATH = File.expand_path('../misc/ui/fonts').gsub(/ /, '\ ')

namespace :install do
  desc 'Make dotfiles/bin executable'
  task :chmod do
    section 'Making dotfiles/bin executable'

    run %( chmod -R +x ~/.dotfiles/bin/ )
  end

  desc 'Install Fish shell'
  task :fish do
    section 'Installing Fish shell and plugins'

    run %( echo $(which fish) | sudo tee -a /etc/shells )
    run %( chsh -s $(which fish) )
    run %( curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher )
    run %( fisher list | fisher install )
  end

  desc 'Install fonts'
  task :fonts do
    section 'Installing fonts'

    unless testing?
      Dir.foreach(FONT_PATH) do |font|
        next if ['.', '..', '.DS_Store'].include?(font)

        escaped_path = FONT_PATH.gsub("'") { "\\'" }
        escaped_path = escaped_path.gsub(' ') { '\\ ' }
        font = font.gsub(' ') { '\\ ' }
        run %( cp #{escaped_path}/#{font} ~/Library/Fonts )
      end
    end
  end

  desc 'Change Hammerspoon directory'
  task :hammerspoon do
    section 'Changing Hammerspoon directory'

    run %( defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua" )
  end

  desc 'Install Launch Agents'
  task :launch_agents do
    section 'Installing Launch Agents'

    run %( launchctl load -w ~/Library/LaunchAgents/oli.cloud-backup.plist )
    run %( launchctl load -w ~/Library/LaunchAgents/oli.color-mode-notify.plist )
  end

  desc 'Install macOS Configurations'
  task :macos do
    section 'Installing macOS Configurations'

    run %( sh ./commands/macos )
  end

  desc 'Install Servers'
  task :servers do
    section 'Installing servers'

    unless testing?
      run %( asdf plugin add python )
      run %( asdf install python 2.7.18 )
      run %( asdf install python 3.11.0 )
      run %( asdf global python 3.11.0 2.7.18 )
      run %( ~/.asdf/shims/python -m pip install --upgrade pip )
      run %( ~/.asdf/shims/python -m pip install pynvim )
      run %( ~/.asdf/shims/python2 -m pip install --upgrade pip )
      run %( ~/.asdf/shims/python2 -m pip install pynvim )

      run %( asdf plugin add ruby )
      run %( asdf install ruby 3.1.1 )
      run %( asdf install ruby 2.7.4 )
      run %( asdf global ruby 3.1.1 )

      run %( asdf plugin add lua )
      run %( asdf install lua 5.4.3 )
      run %( asdf global lua 5.4.3 )

      run %( mv -v "/opt/homebrew/var/postgres" "/opt/homebrew/var/postgresql@14" )
      run %( brew services restart postgresql@14 )
      run %( brew services )

      run %( asdf plugin add nodejs )
      run %( asdf install nodejs latest )
      run %( asdf install nodejs 16.17.0 )
      run %( asdf global nodejs 16.17.0 )
    end
  end
end

namespace :update do
  desc 'Patch fonts'
  task :fonts do
    section 'Patching fonts'

    fontforge_dir = File.expand_path('~/.fontforge')
    input_dir = File.expand_path('~/fonts_to_patch')
    output_dir = File.expand_path('~/patched_fonts')

    unless testing?
      # Check if fontforge is installed
      run %( git clone https://github.com/ryanoasis/nerd-fonts ~/.fontforge ) unless File.directory?(fontforge_dir)

      yesno?("Have you copied fonts to the #{input_dir} folder?")

      run %( cd ~/.fontforge && git pull )
      Dir.foreach(input_dir) do |font|
        run %( cd ~/.fontforge && fontforge -script font-patcher --fontawesome --fontawesomeextension --fontlogos --octicons --codicons --powersymbols --pomicons --powerline --powerlineextra --material --weather --out #{output_dir} #{input_dir}/#{font} )
      end
    end
  end

  desc 'Update Servers'
  task :servers do
    section 'Updating servers'

    run %( asdf plugin update --all )
  end
end
