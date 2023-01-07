namespace :tests do
  desc "Setup tests"
  task :setup do
    section "Setting up the tests"

    if testing?
      DOTS_FOLDER = 'dotfiles'
    end
    run %( cp #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/tests/stubs/app_store.txt #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/misc/packages/app_store.txt)
    run %( cp #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/tests/stubs/python_pip.txt #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/misc/packages/python_pip.txt)
    run %( cp #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/tests/stubs/ruby_gems.txt #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/misc/packages/ruby_gems.txt)
    run %( cp #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/tests/stubs/brew_taps.txt #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/misc/packages/brew_taps.txt)
    run %( cp #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/tests/stubs/.mackup.cfg #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/.config/mackup/.mackup.cfg)
    run %( cp #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/tests/stubs/brew_packages.txt #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/misc/packages/brew_packages.txt)
    run %( cp #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/tests/stubs/brew_cask.txt #{DIRECTORY_NAME + File::SEPARATOR + DOTS_FOLDER}/misc/packages/brew_cask.txt)
  end
end
