#!/usr/bin/env python3

import os
import sys
import subprocess

# The order in which apps are changed
apps = [
    # 'macos',
    # 'wallpaper',
    'alacritty',
    'starship',
    'tmux',
    'neovim_nightly'
]

def app_macos(mode):
    if mode == "dark":
        ascript = 'Application(\'System Events\').appearancePreferences.darkMode = true'

    if mode == "light":
        ascript = 'Application(\'System Events\').appearancePreferences.darkMode = false'

    return subprocess.run(['osascript', '-l', 'JavaScript', '-e', ascript, '>/dev/null'])

def app_wallpaper(mode):
    """
    Change the desktop wallpaper
    """
    wallpaper = {
        'dark': '/System/Library/Desktop Pictures/Valley.heic',
        'light': '/System/Library/Desktop Pictures/Tree.heic'
    }

    ascript = '''
        tell application "Finder" to set desktop picture to POSIX file "{}"
    '''

    return subprocess.run(['osascript', '-e', ascript.format(wallpaper[mode])], capture_output=True)

def app_alacritty(mode):
    """
    Change the Alacritty terminal
    """
    path_to_file = '~/.config/alacritty/alacritty.yml'

    # Safely open the neovim file
    with open(os.path.expanduser(path_to_file), 'r') as config_file:
        contents = config_file.read()

    # Begin changing the modes
    if mode == "dark":
        contents = contents.replace('colors: *light', 'colors: *dark')

    if mode == "light":
        contents = contents.replace('colors: *dark', 'colors: *light')
        
    with open(os.path.expanduser(path_to_file), 'w') as config_file:
        return config_file.write(contents)

def app_starship(mode):
    """
    Change the prompt in the terminal
    """
    if mode == "dark":
        return subprocess.run(['cp', os.path.expanduser('~/.config/starship/starship_dark.toml'), os.path.expanduser('~/.config/starship/starship.toml')])

    if mode == "light":
        return subprocess.run(['cp', os.path.expanduser('~/.config/starship/starship_light.toml'), os.path.expanduser('~/.config/starship/starship.toml')])

def app_tmux(mode):
    if mode == "dark":
        subprocess.run(['cp', os.path.expanduser('~/.tmux/conf/skin_dark.conf'), os.path.expanduser('~/.tmux/conf/skin.conf')])

    if mode == "light":
        subprocess.run(['cp', os.path.expanduser('~/.tmux/conf/skin_light.conf'), os.path.expanduser('~/.tmux/conf/skin.conf')])

    return subprocess.run(['/usr/local/bin/tmux', 'source-file', os.path.expanduser('~/.tmux.conf')])

def app_neovim_nightly(mode):
    """
    Change the Neovim color scheme
    """
    from pynvim import attach

    path_to_nvim_file = '~/.config/nvim/init.lua'

    # Open the neovim file
    with open(os.path.expanduser(path_to_nvim_file), 'r') as config_file:
        nvim_contents = config_file.read()

    # Change the mode to ensure on a fresh startup, the color is remembered
    if mode == "dark":
        nvim_contents = nvim_contents.replace("o.background = 'light'", "o.background = 'dark'")

    if mode == "light":
        nvim_contents = nvim_contents.replace("o.background = 'dark'", "o.background = 'light'")
        
    with open(os.path.expanduser(path_to_nvim_file), 'w') as config_file:
        config_file.write(nvim_contents)

    # Change the neovim via an api call
    try:
        # Open the servers list
        with open(os.path.expanduser("~/.config/nvim/servers.txt"), 'r') as servers_list:
            servers = servers_list.read()
            servers_to_keep = ''

        # Loop through them and change the theme
        for server in servers.split(','):
            try:
                nvim = attach('socket', path=server)
                nvim.command("call v:lua.SetTheme('" + mode + "')")
                servers_to_keep += server + ","
            except:
                continue
            
        # Clear out any redundant servers
        if len(servers_to_keep) > 0:
            with open(os.path.expanduser("~/.config/nvim/servers.txt"), 'w') as servers_list:
                servers_list.write(servers_to_keep)

        return
    except FileNotFoundError:
        return

def run_apps(mode=None):
    """
    Based on the apps in our list, sequentially run and trigger them
    """
    if mode == None:
        mode = get_mode()

    for app in apps:
        getattr(sys.modules[__name__], "app_%s" % app)(mode)

    return

def get_mode():
    """
    Determine what mode macOS is currently in
    """
    mode = subprocess.run(['defaults', 'read', '-g', 'AppleInterfaceStyle', '>/dev/null'], capture_output=True)
    if mode.returncode == 1:
        return 'light'
    else:
        return 'dark'

if __name__ == '__main__':
    # If we've passed a specific mode then activate it
    try:
        run_apps(sys.argv[1])
    except IndexError:
        run_apps()