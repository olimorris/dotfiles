<p align="center">
<img src="https://user-images.githubusercontent.com/9512444/209835727-28652594-1f87-4ff0-ab94-8c2057512e2f.png" alt="Neovim">
</p>

<h1 align="center">Oli's Dotfiles</h1>

<p align="center">
<a href="https://github.com/olimorris/dotfiles/actions/workflows/build.yml"><img src="https://img.shields.io/github/actions/workflow/status/olimorris/dotfiles/build.yml?branch=main&label=build&style=for-the-badge"></a>
</p>

<p align="center">
My macOS dotfiles. Installation instructions are my own
</p>

## :computer: Setting up a new Mac

- Ensure you're signed into iCloud and the App Store
- Download the `~/Code` and `~/.dotfiles` folders from [Koofr](https://koofr.eu)
- Open up a terminal and run:

```bash
cd ~/.dotfiles && rake install
```

- Grab a coffee. This will take a while

## :wrench: What actually happens

- Your [Homebrew](https://brew.sh) and macOS apps will be installed
- Your application settings will be restored with [Mackup](https://github.com/lra/mackup)
- Your dotfiles will be restored with [Dotbot](https://github.com/anishathalye/dotbot)
- Your fonts will be installed
- Your custom launch agents will be installed
- Your development environments will be installed and configured

## :keyboard: Useful commands

- To backup your dotfiles:

```bash
cd ~/.dotfiles && rake backup
```

- To update and backup your dotfiles:

```bash
cd ~/.dotfiles && rake sync
```

## :clap: Thanks

- [Kevin Jalbert](https://kevinjalbert.com/synchronizing-my-dotfiles)
- [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles)
