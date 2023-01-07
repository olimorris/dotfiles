#!/usr/bin/env python3

import os
import sys
import subprocess

kitty_path = "~/.config/kitty"
starship_path = "~/.config/starship"
tmux_path = "~/.config/tmux"
nvim_path = "~/.config/nvim"

# If we toggle dark mode via Alfred, we end up in a infinite loop. The dark-mode
# binary changes the MacOS mode which in turn causes color-mode-notify to run
# this script. This script then calls dark-mode (via the app_macos method)
# which kick starts this loop all over again. We use this boolean var
# to detect when we've run the command via the cmdline or alfred.
ran_from_cmd_line = False

# The order in which apps are changed
apps = [
    "macos",
    "kitty",
    "starship",
    "tmux",
    "neovim",
    "fish",
]

def app_macos(mode):
    """
    Change the macOS environment
    """
    path_to_file = "~/.color_mode"

    # Open the color_mode file
    with open(os.path.expanduser(path_to_file), "r") as config_file:
        contents = config_file.read()

    # Change the mode to ensure on a fresh startup, the color is remembered
    if mode == "dark":
        contents = contents.replace("light", "dark")
        if ran_from_cmd_line:
            subprocess.run(["dark-mode", "on"])

    if mode == "light":
        contents = contents.replace("dark", "light")
        if ran_from_cmd_line:
            subprocess.run(["dark-mode", "off"])

    with open(os.path.expanduser(path_to_file), "w") as config_file:
        config_file.write(contents)

def app_kitty(mode):
    """
    Change the Kitty terminal
    """
    kitty_file = kitty_path + "/kitty.conf"

    # Open the Kitty config
    with open(os.path.expanduser(kitty_file), "r") as config_file:
        contents = config_file.read()

    # Begin changing the modes
    if mode == "dark":
        contents = contents.replace("include ./onelight.conf", "include ./onedark.conf")

    if mode == "light":
        contents = contents.replace("include ./onedark.conf", "include ./onelight.conf")

    with open(os.path.expanduser(kitty_file), "w") as config_file:
        config_file.write(contents)

    # Reload the Kitty config
    # Note: For Kitty 0.23.1, this breaks it
    try:
        pids = subprocess.run(["pgrep", "kitty"], stdout=subprocess.PIPE)
        pids = pids.stdout.splitlines()
        for pid in pids:
            try:
                subprocess.run(["kill", "-SIGUSR1", pid])
            except:
                continue
    except IndexError:
        pass


def app_starship(mode):
    """
    Change the prompt in the terminal
    """
    if mode == "dark":
        return subprocess.run(
            [
                "cp",
                os.path.expanduser(starship_path + "/starship_dark.toml"),
                os.path.expanduser(starship_path + "/starship.toml"),
            ]
        )

    if mode == "light":
        return subprocess.run(
            [
                "cp",
                os.path.expanduser(starship_path + "/starship_light.toml"),
                os.path.expanduser(starship_path + "/starship.toml"),
            ]
        )


def app_tmux(mode):
    if mode == "dark":
        subprocess.run(
            [
                "cp",
                os.path.expanduser(tmux_path + "/conf/skin_dark.conf"),
                os.path.expanduser(tmux_path + "/conf/skin.conf"),
            ]
        )

    if mode == "light":
        subprocess.run(
            [
                "cp",
                os.path.expanduser(tmux_path + "/conf/skin_light.conf"),
                os.path.expanduser(tmux_path + "/conf/skin.conf"),
            ]
        )

    subprocess.run(
        [
            "/opt/homebrew/bin/tmux",
            "source-file",
            os.path.expanduser(tmux_path + "/tmux.conf"),
        ]
    )
    # return os.system("exec zsh")


def app_neovim(mode):
    """
    Change the Neovim color scheme
    """
    from pynvim import attach

    nvim_config = nvim_path + "/lua/Oli/config/options.lua"

    # Open the neovim file
    with open(os.path.expanduser(nvim_config), "r") as config_file:
        nvim_contents = config_file.read()

    # Change the mode to ensure on a fresh startup, the color is remembered
    if mode == "dark":
        nvim_contents = nvim_contents.replace(
            'vim.opt.background = "light"', 'vim.opt.background = "dark"'
        )

    if mode == "light":
        nvim_contents = nvim_contents.replace(
            'vim.opt.background = "dark"', 'vim.opt.background = "light"'
        )

    with open(os.path.expanduser(nvim_config), "w") as config_file:
        config_file.write(nvim_contents)

    # Now begin changing our open Neovim instances

    # Get the neovim servers using neovim-remote
    servers = subprocess.run(["nvr", "--serverlist"], stdout=subprocess.PIPE)
    servers = servers.stdout.splitlines()

    # Loop through them and change the theme by calling our custom Lua code
    for server in servers:
        try:
            nvim = attach("socket", path=server)
            nvim.command("call v:lua.om.ToggleTheme('" + mode + "')")
        except:
            continue

    return

def app_fish(mode):
    return subprocess.run(["/opt/homebrew/bin/fish"])

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
    mode = subprocess.run(
        ["defaults", "read", "-g", "AppleInterfaceStyle", ">/dev/null"],
        capture_output=True,
    )
    if mode.returncode == 1:
        return "light"
    else:
        return "dark"


if __name__ == "__main__":
    # If we've passed a specific mode then activate it
    try:
        if sys.argv[1]:
            ran_from_cmd_line = True
        run_apps(sys.argv[1])
    except IndexError:

        run_apps()
