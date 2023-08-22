<p align="center">
<img src="https://user-images.githubusercontent.com/9512444/224173335-446d701d-cca3-41bd-8889-572a93ddaf41.png" alt="Dotfiles">
</p>

<h1 align="center">Oli's Dotfiles</h1>

<p align="center">
<a href="https://github.com/olimorris/dotfiles/actions/workflows/build.yml"><img src="https://img.shields.io/github/actions/workflow/status/olimorris/dotfiles/build.yml?branch=main&label=build&style=for-the-badge"></a>
</p>

<p align="center">
My macOS dotfiles. Installation instructions are my own<br><br>
Regular Neovim tweaks. Occasional workflow tips worth stealing :smile:
</p>

## :computer: Setting up a new Mac

- Ensure you're signed into iCloud and the App Store
- Download the `~/Code` and `~/.dotfiles` folders from online storage
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

## :floppy_disk: Useful commands

- To backup your dotfiles:

```bash
cd ~/.dotfiles && rake backup
```

- To update and backup your dotfiles:

```bash
cd ~/.dotfiles && rake sync
```

## :keyboard: Useful keymaps

I implement a [Hyperkey](https://hyperkey.app) (<kbd>ctrl</kbd><kbd>opt</kbd><kbd>cmd</kbd>) to allow for faster [application toggling](https://github.com/olimorris/dotfiles/blob/main/.config/hammerspoon/keymaps.lua) and easier to remember app shortcuts.

<details>
  <summary>Click to see the app shortcuts</summary>

- Create a temp email address       <kbd>Hyperkey</kbd><kbd>shift</kbd><kbd>e</kbd>
- Hide my email                     <kbd>Hyperkey</kbd><kbd>shift</kbd><kbd>h</kbd>
- Lock screen                       <kbd>Hyperkey</kbd><kbd>shift</kbd><kbd>l</kbd>
- Pick color with ColorSlurp        <kbd>Hyperkey</kbd><kbd>shift</kbd><kbd>p</kbd>
- Search files                      <kbd>Hyperkey</kbd><kbd>shift</kbd><kbd>f</kbd>
- Search Raindrop bookmarks         <kbd>Hyperkey</kbd><kbd>shift</kbd><kbd>b</kbd>
- Search screen (uses OCR)          <kbd>Hyperkey</kbd><kbd>shift</kbd><kbd>r</kbd>
- Show Cleanshot history            <kbd>Hyperkey</kbd><kbd>shift</kbd><kbd>c</kbd>
- Show clipboard history            <kbd>Hyperkey</kbd><kbd>shift</kbd><kbd>v</kbd>
- Toggle dark mode                  <kbd>Hyperkey</kbd><kbd>shift</kbd><kbd>d</kbd>
- Windows - Center                  <kbd>opt</kbd><kbd>c</kbd>
- Windows - Maximise                <kbd>opt</kbd><kbd>m</kbd>
- Windows - Left half               <kbd>Hyperkey</kbd><kbd>←</kbd>
- Windows - Right half              <kbd>Hyperkey</kbd><kbd>→</kbd>
- Windows - First third             <kbd>Hyperkey</kbd><kbd>↑</kbd>
- Windows - Last two thirds         <kbd>Hyperkey</kbd><kbd>↓</kbd>

> Thanks to this great [Reddit post](https://www.reddit.com/r/macapps/comments/xwfp82/comment/ir6trn4)

</details>

## :clap: Thanks

- [Kevin Jalbert](https://kevinjalbert.com/synchronizing-my-dotfiles)
- [mathiasbynens/dotfiles](https://github.com/mathiasbynens/dotfiles)
