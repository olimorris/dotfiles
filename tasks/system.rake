FONT_PATH = File.expand_path('misc/ui/fonts').gsub(/ /, '\ ')

namespace :install do
  desc 'Make dotfiles/bin executable'
  task :chmod do
    section 'Making dotfiles/bin executable'

    run %( chmod -R +x ~/.dotfiles/bin/ )
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
    run %( launchctl load -w ~/Library/LaunchAgents/oli.finance-output.plist )
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
      run %( mise use --global lua@latest )
      run %( mise install )
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
      if File.directory?(fontforge_dir)
        run %( cd ~/.nerd-fonts && git pull )
      else
        run %( git clone https://github.com/ryanoasis/nerd-fonts ~/.nerd-fonts )
      end

      yesno?("Have you copied fonts to the #{input_dir} folder?")

      run %( cd ~/.nerd-fonts && git pull )
      Dir.foreach(input_dir) do |font|
        run %( cd ~/.nerd-fonts && fontforge -script font-patcher --complete --progressbars --out #{output_dir} #{input_dir}/#{font} )
      end
    end
  end

  desc 'Update Servers'
  task :servers do
    section 'Updating servers'

    run %( mise upgrade )
  end
end
