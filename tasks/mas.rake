MAS_FILE = File.expand_path('~/.dotfiles/misc/packages/app_store.txt', __dir__)

namespace :backup do
  desc 'Backup App Store'
  task :mas do
    section 'Backing up macOS App Store apps'

    run %( mas list \> #{MAS_FILE} )
  end
end

namespace :install do
  desc 'Install mas'
  task :mas do
    section 'Installing macOS App Store apps'

    mas_applications.each do |application|
      run %( mas install #{application} )
    end
  end
end

def mas_applications
  File.readlines(MAS_FILE).map(&:split).map(&:first)
end
