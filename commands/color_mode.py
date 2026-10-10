import subprocess
import sys

# If we toggle dark mode via Alfred, we end up in a infinite loop. The dark-mode
# binary changes the macOS mode which in turn causes color-mode-notify to run
# this script. This script then calls dark-mode (via the app_macos method)
# which kick starts this loop all over again. We use this boolean var
# to detect when we've run the command via the cmdline or Alfred.
ran_from_cmd_line = False

# The order in which apps are changed
apps = [
    "macos",
]


def app_macos(mode):
    """
    Change the macOS environment
    """
    if ran_from_cmd_line:
        subprocess.run(["dark-mode", "on" if mode == "dark" else "off"])

    with open("/tmp/oli-theme", "w") as theme_file:
        theme_file.write(mode)


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
