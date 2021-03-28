namespace :setup do
  desc "Setup tests"
  task :tests do
    section "Setting up the tests"

    if testing?
      DOTS_FOLDER = 'dotfiles'
    end
    run %( cp #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/tests/stubs/mas.txt #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/brew/mas.txt)
    run %( cp #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/tests/stubs/pip.txt #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/brew/pip.txt)
    run %( cp #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/tests/stubs/taps.txt #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/brew/taps.txt)
    run %( cp #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/tests/stubs/.mackup.cfg #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/.mackup.cfg)
    run %( cp #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/tests/stubs/packages.txt #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/brew/packages.txt)
    run %( cp #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/tests/stubs/cask_packages.txt #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/brew/cask_packages.txt)
  end 
end