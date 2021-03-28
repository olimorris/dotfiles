namespace :backup do
  desc 'Backup files using Mackup'
  task :mackup do
    section 'Using Mackup to backup configs'

    if ENV['DRY_RUN']
      puts "~> Chill! It's a dry run"
      system %( mackup backup --dry-run )
    else
      run %( mackup backup --force )
    end
  end
end

namespace :install do
  desc 'Install Mackup'
  task :mackup do
    section 'Installing Mackup'

    if ! File.file?(File.expand_path("~/.mackup.cfg")) && ! ENV['DRY_RUN']
      run %( ln -s #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER + File::SEPARATOR}.mackup.cfg #{"~" + File::SEPARATOR}.mackup.cfg )
      run %( ln -s #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER + File::SEPARATOR}.mackup #{"~" + File::SEPARATOR}.mackup )
    else
      puts "~> Already installed"
    end
  end
end

namespace :restore do
  desc 'Restore files with Mackup'
  task :mackup do
    section 'Using Mackup to restore configs'

    if ENV['DRY_RUN']
      puts "~> Chill! It's a dry run"
      system %( mackup restore --dry-run )
    else
      if ENV['TEST_ENV']
        run %( mackup restore --force )
      else
        run %( mackup restore )
      end
    end
  end
end

namespace :uninstall do
  desc 'Uninstall mackup configs'
  task :mackup do
    section 'Using Mackup to put configs back'

    if ENV['DRY_RUN']
      puts "~> Just a dry run"
      system %( mackup uninstall --dry-run )
    else
      run %( mackup uninstall )
    end
  end
end