#!/bin/bash

obs_folder="$HOME/Movies/OBS"

echo "Looking in: $obs_folder"

# Find the newest file in the folder
newest_file=$(ls -t "$obs_folder"/* 2>/dev/null | head -n 1)

if [ -n "$newest_file" ]; then
    echo "Opening: $newest_file"

    # Try VLC first, fallback to default player
    if [ -d "/Applications/VLC.app" ]; then
        /Applications/VLC.app/Contents/MacOS/VLC --play-and-exit "$newest_file"
    else
        open "$newest_file"
    fi
else
    echo "No files found in the folder."
fi
