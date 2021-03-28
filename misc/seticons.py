import os
import json
from pathlib import Path
from termcolor import cprint

icon_file = str(Path.home()) + '/.dotfiles/misc/ui/icons/icons.json'

# Open the JSON icon file
with open(icon_file) as json_file:
    data = json.load(json_file)
    
    # Loop through each app and begin to replace the icons
    for app in data.values():
        
        # Set the icon paths
        icon = app['new_icon']
        icon = icon.replace(" ", "\ ")
        icon_path = str(Path.home()) + '/.dotfiles/misc/ui/icons/icon_files/' + icon
        
        # Set the application paths
        app_icon = app['icon'].replace(" ", "\ ")
        app_escaped = app['name'].replace(" ", "\ ")
        app_path = '/Applications/' + app['name']
        app_path_escaped = '/Applications/' + app_escaped
        app_new_icon = app_path_escaped + '/Contents/Resources/' + app_icon
        
        # Change the icons via the command line
        if os.path.exists(app_path):
            try:
                if os.system('sudo cp ' + icon_path + ' ' + app_new_icon + ' &> /dev/null') != 0:
                    raise Exception

                if os.system('sudo touch ' + app_path_escaped + ' &> /dev/null') != 0:
                    raise Exception

                cprint ('✔ ' + app['name'], 'green')
            except:
                cprint ('✘ ' + app['name'], 'red')
        else:
            cprint ('✘ ' + app['name'] + ' could not be found', 'red')

# Reload the Finder app and the DockZ
os.system('sudo killall Finder && sudo killall Dock')

# Example JSON file
# {
#     "1Password": {
#         "name": "1Password 7.app",
#         "icon": "1Password.icns",
#         "new_icon": "1Password.icns"
#     },
#     "AppCleaner": {
#         "name": "AppCleaner.app",
#         "icon": "AppCleaner.icns",
#         "new_icon": "AppCleaner.icns"
#     }
# }