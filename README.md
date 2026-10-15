<p align="center">
<img src="https://github.com/user-attachments/assets/52545f6b-1825-462d-b578-14ad27ee9dca" alt="Dotfiles">
</p>

<h1 align="center">Oli's Dotfiles</h1>

<p align="center">
<a href="https://github.com/olimorris/dotfiles/actions/workflows/build.yml"><img src="https://img.shields.io/github/actions/workflow/status/olimorris/dotfiles/build.yml?branch=main&label=build&style=for-the-badge"></a>
</p>

<p align="center">
My macOS dotfiles. Installation instructions are my own<br>
Regular Neovim tweaks. Occasional workflow tips worth stealing :smile:<br>
My current Neovim config can be found <a href="https://github.com/olimorris/dotfiles/tree/main/.config/nvim">here</a>
</p>

## :computer: Setting up a new Mac

- Ensure you're signed into iCloud and the App Store
- Clone the dotfiles:

```bash
git clone https://github.com/olimorris/dotfiles.git ~/.dotfiles
```

- Copy `rclone.conf` from 1Password to `~/.dotfiles/.config/rclone/rclone.conf`
- Copy `.env` from 1Password to `~/.dotfiles/.config/env/.env` and update as required
- Open up a terminal and run:

```bash
cd ~/.dotfiles && rake init
```

- Grab a coffee. This will take a while

## :wrench: What actually happens

- Your [Homebrew](https://brew.sh) and macOS apps will be installed
- Your application settings will be restored via `tasks/mackup.rb`
- Your dotfiles will be restored with [Dotbot](https://github.com/anishathalye/dotbot)
- Your fonts will be installed
- Your custom launch agents will be installed
- Your development environments will be installed and configured

## :floppy_disk: Useful commands

- To move files between Macs (run `backup --help` for the groups and options):

```bash
backup push --dotfiles --code    # Mac -> cloud, newer file wins, nothing deleted
backup pull --dotfiles --code    # cloud -> Mac, newer file wins, nothing deleted
backup sync --dotfiles --code    # push, then pull
backup reset --code              # make this Mac match the cloud, deleting local extras
```

- To apply the files in `~/.dotfiles` to this Mac:

```bash
rake setup             # links, app configs and packages
rake setup:links       # dotbot and agent skills
rake setup:apps        # app configs
rake setup:packages    # brew, casks, App Store, gems, npm, pip. Never uninstalls
rake setup:macos       # macOS defaults, not part of rake setup
```

- To update everything and refresh the package lists:

```bash
cd ~/.dotfiles && rake update
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
