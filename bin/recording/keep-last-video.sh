#!/bin/bash

obs_folder="$HOME/Movies/OBS"
keep_folder="$obs_folder/Keep"

# Find the newest file in the folder
newest_file=$(ls -t "$obs_folder"/* 2>/dev/null | grep -v "/Keep" | head -n 1)

if [ -n "$newest_file" ]; then
    # Create keep folder if it doesn't exist
    mkdir -p "$keep_folder"

    if [[ "$newest_file" == *.mkv ]]; then
        mp4_file="${newest_file%.mkv}.mp4"
        echo "Remuxing to mp4: $newest_file"

        if ffmpeg -y -i "$newest_file" -c copy "$mp4_file"; then
            osascript -e "tell application \"Finder\" to delete POSIX file \"$newest_file\"" 2>/dev/null
            newest_file="$mp4_file"
        else
            echo "Remux failed, keeping original mkv."
        fi
    fi

    echo "Moving to keep folder: $newest_file"

    # Move the file
    mv "$newest_file" "$keep_folder/"

    echo "File moved to keep folder successfully."
else
    echo "No files found in the folder."
fi
