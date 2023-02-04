#!/bin/bash
#your playlists file
playlist_file=/home/kh/md

# Read file and display names of playlists
i=1
while read -r line; do
    name=$(echo $line | awk -F',' '{print $1}')
    echo "$i. $name"
    ((i++))
done < "$playlist_file"

# Ask user to choose a playlist
echo "Enter the number of the playlist you want to download:"
read playlist_choice

# Get URL of chosen playlist
playlist_link=$(sed -n "${playlist_choice}p" $playlist_file | awk -F',' '{print $2}')
playlist_name=$(sed -n "${playlist_choice}p" $playlist_file | awk -F',' '{print $1}')
# Show how many videos in the playlist
video_count=$(youtube-dl --get-id --flat-playlist $playlist_link | wc -l)
if [ $? -ne 0 ]; then
    echo "Error: Invalid playlist link"
    exit 1
fi
echo "There are $video_count videos in the playlist"

youtube-dl --get-title --flat-playlist $playlist_link
# Ask user for start position of videos to download
echo "Enter the start position of the videos to download from the playlist:"
read start_pos

# Validate start position input
if ! [[ $start_pos =~ ^[0-9]+$ ]]; then
    echo "Error: Invalid start position"
    exit 1
fi
if [ $start_pos -lt 1 ] || [ $start_pos -gt $video_count ]; then
    echo "Error: Start position must be between 1 and $video_count"
    exit 1
fi

# Ask user for end position of videos to download
echo "Enter the end position of the videos to download from the playlist:"
read end_pos

# Validate end position input
if ! [[ $end_pos =~ ^[0-9]+$ ]]; then
    echo "Error: Invalid end position"
    exit 1
fi
if [ $end_pos -lt $start_pos ] || [ $end_pos -gt $video_count ]; then
    echo "Error: End position must be between $start_pos and $video_count"
    exit 1
fi

# Ask user if they want to download audio or mp4
echo "Enter 1 to download audio, 2 to download mp4:"
read download_choice

# Validate download choice input
if ! [[ $download_choice =~ ^[12]$ ]]; then
    echo "Error: Invalid choice"
    exit 1
fi

save_location=/home/kh/Media
playlist_directory="$save_location/$playlist_name"


if [ $download_choice -eq 1 ]; then
  # Download audio from the playlist
  youtube-dl --extract-audio --audio-format mp3 -o "$playlist_directory/%(title)s.%(ext)s" --no-playlist -i --yes-playlist --playlist-start $start_pos --playlist-end $end_pos $playlist_link
  if [ $? -ne 0 ]; then
    echo "Error: Failed to download audio"
    exit 1
  fi
else
  # Download mp4 from the playlist
  youtube-dl -f 'bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best' -o "$playlist_directory/%(title)s.%(ext)s" --no-playlist -i --yes-playlist --playlist-start $start_pos --playlist-end $end_pos $playlist_link
  if [ $? -ne 0 ]; then
    echo "Error: Failed to download mp4"
    exit 1
  fi
fi

echo "Download complete!"
