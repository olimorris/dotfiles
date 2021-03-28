# Oli's Dotfiles

[![build](https://github.com/olimorris/dotfiles/actions/workflows/build.yml/badge.svg)](https://github.com/olimorris/dotfiles/actions/workflows/build.yml)

My macOS dotfiles, written in Ruby. Installation instructions are my own.

## Setting up a new Mac

* Install Tresorit and sync the `.dotfiles` Tresor to `~/` (wait for full sync to take place!)
* Ensure you're signed into iCloud and the App Store
* Open up a terminal and run:
```bash
cd ~/.dotfiles && rake install
```
* Install Aqueux for your beautiful wallpaper transitions

## What actually happens

* All of your Homebrew and macOS apps will be installed
* All of your application settings from Mackup will be restored
* Your fonts will be installed
* Your development environment will be installed

## Things to note

* Your Neovim Nightly plugins *may* be screwed if they don't copy over perfectly

## Final steps

* Be sure to link this GitHub repo to your new Mac
* Sync your Code Tresor to `~/Code`

## Useful commands

* To backup your dotfiles:
```bash
cd ~/.dotfiles && rake backup
```
* To update and backup your dotfiles:
```bash
cd ~/.dotfiles && rake sync
```

## Credits

* [Kevin Jalbert](https://kevinjalbert.com/synchronizing-my-dotfiles/)
* [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles)
