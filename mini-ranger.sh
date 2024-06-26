#!/bin/bash
#
# NOTE: for more logos https://fontawesome.com/search

current_dir=$(pwd)
current_selection=0
sub_selection=0

# Path to the image you want to display
image_path="../../Pictures/wallpapers/Law1.jpg"

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
COLOR_HIGHLIGHT='\e[30m\e[47m'
COLOR_DEFAULT='\e[0;37m'

# File extension color codes
declare -A FILE_COLORS
FILE_COLORS=(
  ["sh"]='\e[0;33m'    # Shell script - Yellow
  ["py"]='\e[0;35m'    # Python - Magenta
  ["cpp"]='\e[0;36m'   # C++ - Cyan
  ["c"]='\e[0;36m'     # C - Cyan
  ["h"]='\e[0;36m'     # C/C++ Header - Cyan
  ["java"]='\e[0;31m'  # Java - Red
  ["js"]='\e[0;33m'    # JavaScript - Yellow
  ["html"]='\e[0;35m'  # HTML - Magenta
  ["css"]='\e[0;32m'   # CSS - Green
  ["md"]='\e[0;34m'    # Markdown - Blue
  ["txt"]='\e[0;37m'   # Text file - Light Gray
  ["pdf"]='\e[0;31m'   # PDF - Red
  ["jpg"]='\e[0;33m'   # JPEG image - Yellow
  ["jpeg"]='\e[0;33m'  # JPEG image - Yellow
  ["png"]='\e[0;33m'   # PNG image - Yellow
  ["gif"]='\e[0;33m'   # GIF image - Yellow
  ["zip"]='\e[0;31m'   # ZIP archive - Red
  ["tar"]='\e[0;31m'   # TAR archive - Red
  ["gz"]='\e[0;31m'    # GZ archive - Red
  ["mp3"]='\e[0;35m'   # MP3 audio - Magenta
  ["wav"]='\e[0;35m'   # WAV audio - Magenta
  ["mp4"]='\e[0;35m'   # MP4 video - Magenta
  ["mkv"]='\e[0;35m'   # MKV video - Magenta
  ["doc"]='\e[0;34m'   # Word document - Blue
  ["docx"]='\e[0;34m'  # Word document - Blue
  ["json"]='\e[0;36m'  # JSON file - Cyan
  ["xml"]='\e[0;36m'   # XML file - Cyan
)

# Icon mapping based on file extensions
declare -A FILE_ICONS
FILE_ICONS=(
  ["sh"]="🐚"      # Shell script
  ["py"]=""       # Python
  ["cpp"]="🌐"     # C++
  ["c"]="🌐"       # C
  ["h"]="🌐"       # C/C++ Header
  ["java"]="☕"    # Java
  ["js"]=""       # JavaScript
  ["html"]="🌐"    # HTML
  ["css"]="🎨"     # CSS
  ["md"]="📝"      # Markdown
  ["txt"]="📄"     # Text file
  ["pdf"]="📚"     # PDF
  ["jpg"]="🖼️"     # JPEG image
  ["jpeg"]="🖼️"    # JPEG image
  ["png"]="🖼️"     # PNG image
  ["gif"]="🖼️"     # GIF image
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
  ["xml"]=""      # XML file
)

# Function to list files and directories
list_files() {
  ls -1 --group-directories-first "$current_dir"
}

list_sub_files() {
  local dir="$1"
  ls -1 --group-directories-first "$dir"
}

# Function to display files with appropriate colors and icons
display_files_with_colors() {
  local file="$1"
  local extension="${file##*.}"
  local icon="${FILE_ICONS[$extension]}"
  local color="${FILE_COLORS[$extension]}"
  
  if [ $current_selection -eq $2 ]; then
    echo -e "${COLOR_HIGHLIGHT}${file}${COLOR_RESET}"
  elif [ -d "$current_dir/$file" ]; then
    echo -e "${COLOR_DIR}${file}${COLOR_RESET}"
  elif [ -x "$current_dir/$file" ]; then
    echo -e "${COLOR_EXE}${file}${COLOR_RESET}"
  else
    if [ -n "$icon" ]; then
      echo -e "$icon ${color}${file}${COLOR_RESET}"
    else
      echo -e "${COLOR_DEFAULT}${file}${COLOR_RESET}"
    fi
  fi
}

# Function to display the current directory and list files with highlighting
display() {
  clear
  display_image
  echo "Current directory: $current_dir"
  echo "---------------------------------------------------------------"
  files=($(list_files))
  sub_dir=""
  sub_files=()

  if [ -d "$current_dir/${files[$current_selection]}" ]; then
    sub_dir="$current_dir/${files[$current_selection]}"
    sub_files=($(list_sub_files "$sub_dir"))
  fi

  # Table header
  printf "┃ \e[1;36m%-35s\e[0m ┃ \e[1;36m%-35s\e[0m ┃\n" "Main Directory" "Subdirectories"
  echo "---------------------------------------------------------------"

  max_files=${#files[@]}
  max_sub_files=${#sub_files[@]}
  max_lines=$(( max_files > max_sub_files ? max_files : max_sub_files ))

  for (( i=0; i<$max_lines; i++ )); do
    # Display main directory files
    printf "┃ %-35s ┃" "$(display_files_with_colors "${files[$i]:- }" $i)"

    # Display subdirectory files
    if [ $i -lt ${#sub_files[@]} ]; then
      printf " %-35s ┃\n" "$(display_files_with_colors "${sub_files[$i]:- }" $i)"
    else
      printf " %-35s ┃\n" ""
    fi
  done

  echo "Use 'h' or left arrow to go up, 'j' or down arrow to navigate, 'k' or up arrow to navigate, 'l' or right arrow to enter, 'o' to open with default application, 'q' to quit"
}

# Function to display preview of text files using bat
display_preview() {
  local file="$1"
  bat --style=numbers --color=always "$file"
}

# Function to navigate directories
navigate() {
  while true; do
    display
    read -rsn1 key
    if [[ $key == $'\e' ]]; then
      read -rsn2 key
    fi
    case $key in
      q) break ;;
      h|'[D')
        current_dir=$(dirname "$current_dir")
        current_selection=0
        sub_selection=0
        ;;
      j|'[B')
        current_selection=$((current_selection + 1))
        if [ $current_selection -ge ${#files[@]} ]; then
          current_selection=0
        fi
        sub_selection=0
        ;;
      k|'[A')
        current_selection=$((current_selection - 1))
        if [ $current_selection -lt 0 ]; then
          current_selection=$((${#files[@]} - 1))
        fi
        sub_selection=0
        ;;
      l|'[C')
        if [ -d "$current_dir/${files[$current_selection]}" ]; then
          current_dir="$current_dir/${files[$current_selection]}"
          current_selection=0
          sub_selection=0
        else
          echo "Not a directory"
          sleep 1
        fi
        ;;
     o)
        local selected_file="${files[$current_selection]}"
        local file_extension="${selected_file##*.}"

        if [ -f "$current_dir/$selected_file" ]; then
          case "$file_extension" in
            sh|py|c|txt|md|css|js|html|json)
              nvim "$current_dir/$selected_file"
              ;;
            *)
              xdg-open "$current_dir/$selected_file"
              ;;
          esac
        else
          echo "Not a file"
          sleep 1
        fi
        ;;
     p)  # Preview file contents
        local selected_file="${files[$current_selection]}"
        local file_extension="${selected_file##*.}"
        if [ -f "$current_dir/$selected_file" ]; then
          case "$file_extension" in
            sh|py|txt|*)  # Add more file types as needed
              clear
              display_image
              echo "Previewing: $selected_file"
              echo "---------------------------------------------------------------"
              display_preview "$current_dir/$selected_file"
              read -n 1 -s -r -p "Press any key to continue"
              ;;
            *)
              echo "Preview not supported for this file type."
              sleep 1
              ;;
          esac
        else
          echo "Not a file"
          sleep 1
        fi
        ;;
    esac
    done
}

navigate
