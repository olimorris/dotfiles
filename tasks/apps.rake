namespace(:install) do
  desc("Install Vim plugins")
  task(:vim) do
    section("Installing Vim plugins")

    unless testing?
      # -p: ~/.vim doesn't exist on a fresh Mac, and a plain mkdir also fails on
      # every re-run once the directories are there.
      run(" mkdir -p ~/.vim/swp ")
      run(" mkdir -p ~/.vim/undo ")
      run(
        " curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim "
      )
      run(" vim +PlugInstall +qall ")
    end
  end

  desc("Install Neovim")
  task(:neovim) do
    section("Installing Neovim")

    unless testing?
      # nvimv exits non-zero on a tag it already has, so guard the call rather than
      # let every re-run of `rake install` report two failures that aren't failures.
      %w[stable nightly].each do |tag|
        run(" nvimv ls | grep -qx #{tag} || nvimv install #{tag} ")
      end
    end

    run(" nvim --headless +'OneDarkProExtras' +qall ")
  end

  desc("Install herdr plugins")
  task(:herdr) do
    section("Installing herdr plugins")

    run(" herdr plugin install salkhalil/herdr-sessionizer --yes ") unless testing?
    run(" herdr plugin install qu8n/herdr-automatic-rename --yes ") unless testing?
    run(" herdr plugin install tajdien/herdr-confirm-close --yes ") unless testing?
  end
end

namespace(:update) do
  desc("Update Vim plugins")
  task(:vim) do
    section("Updating Vim plugins")

    run(" vim +PlugUpdate +qall ") unless testing?
  end

  desc("Update Neovim")
  task(:neovim) do
    section("Updating Neovim")

    run(" nvimv upgrade stable ") unless testing?
    run(" nvimv upgrade nightly ") unless testing?
    run(" nvim --headless +'OneDarkProExtras' +qall")
  end
end
