#!/bin/bash

obs_folder="$HOME/Movies/OBS"
keep_folder="$obs_folder/Keep"

# Find the newest file in the folder
newest_file=$(ls -t "$obs_folder"/* 2>/dev/null | grep -v "/Keep" | head -n 1)

if [ -n "$newest_file" ]; then
    echo "Moving to keep folder: $newest_file"

    # Create keep folder if it doesn't exist
    mkdir -p "$keep_folder"

    # Move the file
    mv "$newest_file" "$keep_folder/"

    echo "File moved to keep folder successfully."
else
    echo "No files found in the folder."
fi
