namespace(:install) do
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

  task(:herdr) do
    section("Installing herdr plugins")

    run(" herdr plugin install fullerzz/herdr-plugin-sesh --yes ") unless testing?
    run(" herdr plugin install tajdien/herdr-confirm-close --yes ") unless testing?
    run(" herdr plugin install devashish2203/herdr-worktrunk --yes ") unless testing?
  end

  task(:rex) do
    section("Installing rex plugins")

    run(" [ -d ~/.config/rex/rex-worktrunk ] || git clone https://github.com/haxybaxy/rex-worktrunk ~/.config/rex/rex-worktrunk ") unless testing?
    run(" [ -d ~/.config/rex/rex-sessionizer ] || git clone https://github.com/haxybaxy/rex-sessionizer ~/.config/rex/rex-sessionizer ") unless testing?
  end
end

namespace(:update) do
  task(:neovim) do
    section("Updating Neovim")

    run(" nvimv upgrade stable ") unless testing?
    run(" nvimv upgrade nightly ") unless testing?
    run(" nvim --headless +'OneDarkProExtras' +qall")
  end

  task(:herdr) do
    section("Updating herdr plugins")

    run(" herdr plugin update ") unless testing?
  end

  task(:rex) do
    section("Updating rex plugins")

    run(" git -C ~/.config/rex/rex-worktrunk pull ") unless testing?
    run(" git -C ~/.config/rex/rex-sessionizer pull ") unless testing?
  end
end
