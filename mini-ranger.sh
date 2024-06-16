#!/bin/bash

current_dir=$(pwd)
current_selection=0

# Path to the image you want to display (use absolute path)
image_path="/home/harshitpdhanwalkar/Pictures/wallpapers/Law1.jpg"

# Function to display the image in the top-right corner
display_image() {
  # Clear any previous image first to avoid overlap
  kitty +kitten icat --clear

  # Display the image in the top right corner
  terminal_width=$(tput cols)
  terminal_height=$(tput lines)
  image_width=40  # Adjust this value as needed
  image_height=20  # Adjust this value as needed
  x_pos=$((terminal_width - image_width))
  y_pos=0

  kitty +kitten icat --align right --place ${image_width}x${image_height}@${x_pos}x${y_pos} "$image_path"
}

# Color codes
COLOR_RESET='\e[0m'
COLOR_DIR='\e[1;34m'
COLOR_EXE='\e[1;32m'
COLOR_HIGHLIGHT='\e[1;37m\e[41m'  # White text on red background

# Icon mapping based on file extensions
declare -A FILE_ICONS
FILE_ICONS=(
  ["sh"]="🐚"      # Shell script
  ["py"]="🐍"      # Python
  ["cpp"]="🌐"     # C++
  ["c"]="🌐"       # C
  ["h"]="🌐"       # C/C++ Header
  ["java"]="☕"    # Java
  ["js"]="📜"      # JavaScript
  ["html"]="🌐"    # HTML
  ["css"]="🎨"     # CSS
  ["md"]="📝"      # Markdown
  ["txt"]="📄"     # Text file
  ["pdf"]="📚"     # PDF
  ["jpg"]="🖼️"    # JPEG image
  ["jpeg"]="🖼️"   # JPEG image
  ["png"]="🖼️"    # PNG image
  ["gif"]="🖼️"    # GIF image
  ["zip"]="📦"     # ZIP archive
  ["tar"]="📦"     # TAR archive
  ["gz"]="📦"      # GZ archive
  ["mp3"]="🎵"     # MP3 audio
  ["wav"]="🎵"     # WAV audio
  ["mp4"]="🎥"     # MP4 video
  ["mkv"]="🎥"     # MKV video
  ["doc"]="📃"     # Word document
  ["docx"]="📃"    # Word document
  ["json"]="🔧"    # JSON file
  ["xml"]="🔧"     # XML file
)

# Function to list files and directories
list_files() {
  ls -1 --group-directories-first "$current_dir"
}

# Function to display files with appropriate colors and icons
display_files_with_colors() {
  local file="$1"
  local extension="${file##*.}"
  local icon="${FILE_ICONS[$extension]}"
  
  if [ -d "$current_dir/$file" ]; then
    echo -e "${COLOR_DIR}$file${COLOR_RESET}"
  elif [ -x "$current_dir/$file" ]; then
    echo -e "${COLOR_EXE}$file${COLOR_RESET}"
  else
    if [ -n "$icon" ]; then
      echo -e "$icon $file"
    else
      echo "$file"
    fi
  fi
}

# Function to display the current directory and list files with highlighting
display() {
  clear
  display_image
  echo "Current directory: $current_dir"
  echo "----------------------------"
  files=($(list_files))
  for i in "${!files[@]}"; do
    if [ $i -eq $current_selection ]; then
      echo -e "${COLOR_HIGHLIGHT}${files[$i]}${COLOR_RESET}"
      if [ -d "$current_dir/${files[$i]}" ]; then
        echo "Subdirectory contents:"
        subfiles=($(ls -1 --group-directories-first "$current_dir/${files[$i]}"))
        for subfile in "${subfiles[@]}"; do
          echo -n "  "
          display_files_with_colors "$subfile"
        done
      fi
    else
      display_files_with_colors "${files[$i]}"
    fi
  done
  echo "----------------------------"
  echo "Use 'h' to go up, 'j' and 'k' to navigate, 'l' to enter, 'o' to open with nvim, 'q' to quit"
}

# Function to navigate directories
navigate() {
  while true; do
    display
    read -n1 -s key
    case $key in
      q) break ;;
      h) current_dir=$(dirname "$current_dir") ;;
      j)
        current_selection=$((current_selection + 1))
        if [ $current_selection -ge ${#files[@]} ]; then
          current_selection=0
        fi
        ;;
      k)
        current_selection=$((current_selection - 1))
        if [ $current_selection -lt 0 ]; then
          current_selection=$((${#files[@]} - 1))
        fi
        ;;
      l)
        if [ -d "$current_dir/${files[$current_selection]}" ]; then
          current_dir="$current_dir/${files[$current_selection]}"
          current_selection=0
        else
          echo "Not a directory"
          sleep 1
        fi
        ;;
      o)
        if [ -f "$current_dir/${files[$current_selection]}" ]; then
          nvim "$current_dir/${files[$current_selection]}"
        else
          echo "Not a file"
          sleep 1
        fi
        ;;
    esac
  done
}

navigate
