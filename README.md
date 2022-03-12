# Oli's Dotfiles

[![build](https://github.com/olimorris/dotfiles/actions/workflows/build.yml/badge.svg)](https://github.com/olimorris/dotfiles/actions/workflows/build.yml)

My macOS dotfiles. Installation instructions are my own.

<img src="https://user-images.githubusercontent.com/9512444/157864043-467d8517-a1e2-4b75-a02e-4449405412f8.png" alt="Neovim">

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

* All of your Homebrew and macOS apps will be installed
* All of your application settings from [Mackup](https://github.com/lra/mackup) will be restored
* All of your fonts will be installed
* All of your custom launch agents will be installed
* All of your development environments will be installed and configured

## :page_facing_up: Things to note

* When you run `Neovim` for the first time all of your plugins will automatically install
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

* [Kevin Jalbert](https://kevinjalbert.com/synchronizing-my-dotfiles/)
* [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles)
