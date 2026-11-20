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

  task(:rex) do
    section("Installing rex plugins")

    unless testing?
      run(
        " [ -d ~/.config/rex/rex-worktrunk ] || git clone https://github.com/haxybaxy/rex-worktrunk ~/.config/rex/rex-worktrunk "
      )
    end

    unless testing?
      run(
        " [ -d ~/.config/rex/rex-floaters ] || git clone https://github.com/enkelm/rex-floaters ~/.config/rex/rex-floaters "
      )
    end

    unless testing?
      run(
        " [ -d ~/.config/rex/rex-sessionizer ] || git clone https://github.com/haxybaxy/rex-sessionizer ~/.config/rex/rex-sessionizer "
      )
    end

    unless testing?
      run(" curl -fsSL https://raw.githubusercontent.com/YangJonghun/rex-agent-resume/main/install.sh | sh ")
    end
  end
end

namespace(:update) do
  task(:neovim) do
    section("Updating Neovim")

    run(" nvimv upgrade stable ") unless testing?
    run(" nvimv upgrade nightly ") unless testing?
    run(" nvim --headless +'OneDarkProExtras' +qall")
  end

  task(:rex) do
    section("Updating rex plugins")

    run(" git -C ~/.config/rex/rex-worktrunk pull ") unless testing?
    run(" git -C ~/.config/rex/rex-floaters pull ") unless testing?
    run(" git -C ~/.config/rex/rex-sessionizer pull ") unless testing?
    unless testing?
      run(" curl -fsSL https://raw.githubusercontent.com/YangJonghun/rex-agent-resume/main/install.sh | sh ")
    end
  end
end
