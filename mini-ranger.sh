#!/bin/bash
#
# NOTE: for more logos https://fontawesome.com/search
# TODO: search files modification
# TODO: Bookmark directories or files
# TODO: preview functionality for text files (\*.txt, \*.sh) using tools like head, tail, or bat to show a snippet of the file content
# TODO: Display files size
# TODO: Mouse support
# TODO: Caching: Implement caching mechanisms to speed up directory listing and navigation, especially for directories with a large number of files. 

current_dir=$(pwd)
current_selection=0
sub_selection=0
search_term=""

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
COLOR_DIR='\e[1;34m'      # Blue
COLOR_EXE='\e[1;32m'      # Green
COLOR_HIGHLIGHT='\e[1;31m\e[47m'  # Bold Red text on White background
COLOR_DEFAULT='\e[0;37m'  # Light gray

# File extension color codes
declare -A FILE_COLORS
FILE_COLORS=(
  ["sh"]="${COLOR_YELLOW}"      # Shell script - Yellow
  ["py"]="${COLOR_MAGENTA}"     # Python - Magenta
  ["cpp"]="${COLOR_CYAN}"       # C++ - Cyan
  ["c"]="${COLOR_CYAN}"         # C - Cyan
  ["h"]="${COLOR_CYAN}"         # C/C++ Header - Cyan
  ["java"]="${COLOR_MAGENTA}"   # Java - Magenta
  ["js"]="${COLOR_YELLOW}"      # JavaScript - Yellow
  ["html"]="${COLOR_MAGENTA}"   # HTML - Magenta
  ["css"]="${COLOR_CYAN}"       # CSS - Cyan
  ["md"]="${COLOR_CYAN}"        # Markdown - Cyan
  ["txt"]="${COLOR_CYAN}"       # Text file - Cyan
  ["pdf"]="${COLOR_MAGENTA}"    # PDF - Magenta
  ["jpg"]="${COLOR_YELLOW}"     # JPEG image - Yellow
  ["jpeg"]="${COLOR_YELLOW}"    # JPEG image - Yellow
  ["png"]="${COLOR_YELLOW}"     # PNG image - Yellow
  ["gif"]="${COLOR_YELLOW}"     # GIF image - Yellow
  ["zip"]="${COLOR_MAGENTA}"    # ZIP archive - Magenta
  ["tar"]="${COLOR_MAGENTA}"    # TAR archive - Magenta
  ["gz"]="${COLOR_MAGENTA}"     # GZ archive - Magenta
  ["mp3"]="${COLOR_CYAN}"       # MP3 audio - Cyan
  ["wav"]="${COLOR_CYAN}"       # WAV audio - Cyan
  ["mp4"]="${COLOR_CYAN}"       # MP4 video - Cyan
  ["mkv"]="${COLOR_CYAN}"       # MKV video - Cyan
  ["doc"]="${COLOR_CYAN}"       # Word document - Cyan
  ["docx"]="${COLOR_CYAN}"      # Word document - Cyan
  ["ppt"]="${COLOR_CYAN}"       # Presentation - Cyan
  ["json"]="${COLOR_YELLOW}"    # JSON file - Yellow
  ["xml"]="${COLOR_YELLOW}"     # XML file - Yellow
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
  ["ppt"]="📃"     # Presentation
  ["json"]="🔧"    # JSON file
  ["xml"]=""      # XML file
)

# Function to list files and directories
list_files() {
  if [ -z "$search_term" ]; then
    ls -1 --group-directories-first "$current_dir"
  else
    find "$current_dir" -maxdepth 1 -iname "*$search_term*" -printf "%f\n"
  fi
}

# Function to list sub-files
list_sub_files() {
  local dir="$1"
  if [ -z "$search_term" ]; then
    ls -1 --group-directories-first "$dir"
  else
    find "$dir" -maxdepth 1 -iname "*$search_term*" -printf "%f\n"
  fi
}

# Function to display files with appropriate colors and icons
display_files_with_colors() {
  local file="$1"
  local index="$2"
  local extension="${file##*.}"
  local icon="${FILE_ICONS[$extension]}"
  local color="${FILE_COLORS[$extension]}"
  
  if [ "$current_selection" -eq "$index" ]; then
    if [ -d "$current_dir/$file" ]; then
      echo -e "${COLOR_HIGHLIGHT}${COLOR_DIR}${file}${COLOR_RESET}"
    elif [ -x "$current_dir/$file" ]; then
      echo -e "${COLOR_HIGHLIGHT}${COLOR_EXE}${file}${COLOR_RESET}"
    else
      if [ -n "$icon" ]; then
        echo -e "${COLOR_HIGHLIGHT}$icon ${color}${file}${COLOR_RESET}"
      else
        echo -e "${COLOR_HIGHLIGHT}${COLOR_DEFAULT}${file}${COLOR_RESET}"
      fi
    fi
  else
    if [ -d "$current_dir/$file" ]; then
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
  fi
}

# Function to display the current directory and list files with highlighting
display() {
  clear
  display_image
  echo "Current directory: $current_dir"
  echo "-----------------------------------------------------------------------------"
  files=($(list_files))
  sub_dir=""
  sub_files=()

  if [ -d "$current_dir/${files[$current_selection]}" ]; then
    sub_dir="$current_dir/${files[$current_selection]}"
    sub_files=($(list_sub_files "$sub_dir"))
  fi

  # Table header
  printf "┃ \e[1;36m%-35s\e[0m ┃ \e[1;36m%-35s\e[0m ┃\n" "Main Directory" "Subdirectories"
  echo "----------------------------------------------------------------------------"

  max_files=${#files[@]}
  max_sub_files=${#sub_files[@]}
  max_lines=$(( max_files > max_sub_files ? max_files : max_sub_files ))

  for (( i=0; i<$max_lines; i++ )); do
    # Display main directory files
    main_file_display=$(display_files_with_colors "${files[$i]:- }" "$i")
    printf "┃ %-35s ┃" "$main_file_display"

    # Display subdirectory files
    sub_file_display=""
    if [ -n "$sub_dir" ] && [ $i -lt ${#sub_files[@]} ]; then
      sub_file_display=$(display_files_with_colors "${sub_files[$i]:- }" "$i")
    fi
    printf " %-35s ┃\n" "$sub_file_display"
  done

  echo "----------------------------------------------------------------------------"
}

# Function to display preview of text files using bat
display_preview() {
  local file="$1"
  bat --style=numbers --color=always "$file"
}

# Function to rename selected file
rename_file() {
  local selected_file="${files[$current_selection]}"
  echo -n "Enter new name for $selected_file: "
  read new_name
  mv "$current_dir/$selected_file" "$current_dir/$new_name"
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
            sh|py|txt|js|md|css|html|json|zsh|bash)  # Add more file types as needed
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
      r)  # Rename file
        if [ -f "$current_dir/${files[$current_selection]}" ]; then
          rename_file
        else
          echo "Not a file"
          sleep 1
        fi
        ;;
      s)  # Search files
        echo -n "Enter search term: "
        read search_term
        current_selection=0  # Reset selection after search
        ;;
    esac
  done
}

navigate
