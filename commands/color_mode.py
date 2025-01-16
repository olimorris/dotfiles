import os
import subprocess
import sys

starship_path = "~/.config/starship"

# If we toggle dark mode via Alfred, we end up in a infinite loop. The dark-mode
# binary changes the MacOS mode which in turn causes color-mode-notify to run
# this script. This script then calls dark-mode (via the app_macos method)
# which kick starts this loop all over again. We use this boolean var
# to detect when we've run the command via the cmdline or alfred.
ran_from_cmd_line = False

# The order in which apps are changed
apps = [
    "macos",
    "starship",
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
    try:
        subprocess.run(
            ["defaults", "read", "-g", "AppleInterfaceStyle"],
            capture_output=True,
            check=True,
            timeout=5,
        )
        return "dark"
    except subprocess.CalledProcessError:
        return "light"


if __name__ == "__main__":
    # If we've passed a specific mode then activate it
    try:
        if sys.argv[1]:
            ran_from_cmd_line = True
        run_apps(sys.argv[1])
    except IndexError:
        run_apps()
