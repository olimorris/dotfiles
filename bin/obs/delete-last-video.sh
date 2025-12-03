#!/bin/bash

obs_folder="/Users/Oli/Movies/OBS"

# Find the newest file in the folder
newest_file=$(ls -t "$obs_folder"/* 2>/dev/null | head -n 1)

if [ -n "$newest_file" ]; then
    echo "Moving to trash: $newest_file"

    osascript -e "tell application \"Finder\" to delete POSIX file \"$newest_file\"" 2>/dev/null

    echo "File moved to trash successfully."
else
    echo "No files found in the folder."
fi
