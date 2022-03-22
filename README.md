# Oli's Dotfiles

[![build](https://github.com/olimorris/dotfiles/actions/workflows/build.yml/badge.svg)](https://github.com/olimorris/dotfiles/actions/workflows/build.yml)

My macOS dotfiles. Installation instructions are my own.

<img src="https://user-images.githubusercontent.com/9512444/159372914-ffbdf2dd-d5c1-43b2-9534-5e9e0fa1a124.png" alt="Neovim">

## :computer: Setting up a new Mac

* Download and install Tresorit and sync the `.dotfiles` Tresor to `~/` (wait for full sync to take place!)
* Ensure you're signed into iCloud and the App Store
* Open up a terminal and run:
```bash
cd ~/.dotfiles && rake install
```
* Install Aqueux for your beautiful wallpaper transitions
* Ensure that `.dotfiles` is linked to your GitHub repo

## :wrench: What actually happens

* Your [Homebrew](https://brew.sh) and macOS apps will be installed
* Your application settings will be restored with [Mackup](https://github.com/lra/mackup)
* Your dotfiles will be restored with [Dotbot](https://github.com/anishathalye/dotbot)
* Your fonts will be installed
* Your custom launch agents will be installed
* Your development environments will be installed and configured

## :page_facing_up: Things to note

* Your plugins will automatically install when you run [neovim](https://github.com/neovim/neovim) for the first time
* Sync your Code Tresor to `~/Code`

### Syncing to GitHub

* This is required as you disable the backing up of `.git` folders in Tresorit
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
