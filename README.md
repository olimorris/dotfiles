<p align="center">
<img src="https://user-images.githubusercontent.com/9512444/182719099-42c62c9e-47c7-43f3-9bfb-65f59004852a.png" alt="Neovim">
</p>

<h1 align="center">Oli's Dotfiles</h1>

<p align="center">
<a href="https://github.com/olimorris/dotfiles/actions/workflows/build.yml"><img src="https://img.shields.io/github/workflow/status/olimorris/dotfiles/build?label=build&style=for-the-badge"></a>
</p>

<p align="center">
My macOS dotfiles. Installation instructions are my own
</p>

## :computer: Setting up a new Mac

* Ensure you're signed into iCloud and the App Store
* Download the `~/Code` and `~/Dotfiles` folders in iCloud Drive
* Open up a terminal and run:
```bash
cd ~/Library/Mobile Documents/com~apple~CloudDocs/Dotfiles && rake install
```
* Install Aqueux for your beautiful wallpaper transitions
* Ensure that `~/.dotfiles` is linked to your GitHub repo

## :wrench: What actually happens

* Your [Homebrew](https://brew.sh) and macOS apps will be installed
* Your application settings will be restored with [Mackup](https://github.com/lra/mackup)
* Your dotfiles will be restored with [Dotbot](https://github.com/anishathalye/dotbot)
* Your fonts will be installed
* Your custom launch agents will be installed
* Your development environments will be installed and configured

## :page_facing_up: Things to note

* Your plugins will automatically install when you run [Neovim](https://github.com/neovim/neovim) for the first time

### Syncing to GitHub

* If your `rakefile` has run as intended, `~/.dotfiles` should be synced to GitHub
* Run `git status` to confirm this is the case. You will see the working tree changes (if any)

## :keyboard: Useful commands

* To backup your dotfiles:
```bash
cd ~/.dotfiles && rake backup
```
* To update and backup your dotfiles:
```bash
cd ~/.dotfiles && rake sync
```

## :clap: Thanks

* [Kevin Jalbert](https://kevinjalbert.com/synchronizing-my-dotfiles)
* [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles)
