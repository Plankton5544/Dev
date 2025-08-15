#!/bin/bash

## Author: Plankton5544
### Date Of Creation: August 14 2025
# Idea: Main Control Panel For Bash Scripts
# Features:
# Dynamically Showing Scripts (e.g. Checks Files)
# Editing Files Automatically (Obviously with NVIM)
##


cut() {
  sfile=${file//".sh"/}
  sfile=${sfile//"/home/plankton/dev/bashscripts/"/}
}



file_echo() {
  for file in "${files[@]}"; do
    printf "$file\n"
  done
}

clear() {
      printf "\033c"
}

file_check() {
for file in ~/dev/bashscripts/*.sh; do
  if [ -e "$file" ]; then
    file=${file//".sh"/}
    file=${file//"/home/plankton/dev/bashscripts/"/}
    files+=("$file")
  fi
done
}


welcome_screen() {
  clear
  printf "
   ____    _    ____  _   _    ____ _____ _   _ _____ ____      _    _
  | __ )  / \  / ___|| | | |  / ___| ____| \ | |_   _|  _ \    / \  | |
  |  _ \ / _ \ \___ \| |_| | | |   |  _| |  \| | | | | |_) |  / _ \ | |
  | |_) / ___ \ ___) |  _  | | |___| |___| |\  | | | |  _ <  / ___ \| |___
  |____/_/   \_\____/|_| |_|  \____|_____|_| \_| |_| |_| \_\/_/   \_\_____|\n "

  printf "\n|==AVAILABLE SCRIPTS==|\n"

  file_echo

  printf "\n|==ACTIONS==|\n"
  printf "Quit    (q)\n"
  printf "Execute (e)\n"
  printf "Edit    (i)\n"

  printf "\n|==What Would You Like To Do?==|\n"
}



file_check
welcome_screen


read -p "=>" action



if [[ "$action" == *"e"* ]]; then
  clear
  printf "|==EXECUTE==|\n"
  #Echoes files inside of files
  for item in "${files[@]}"; do
    printf "$item\n"
  done
  read -p "=>" input

  for file in ~/dev/bashscripts/*.sh; do
    if [[ "$file" == *"$input"* ]]; then
      cut
      printf "Executing $sfile\n"

      clear
      exec bash $file
    fi
  done

elif [[ "$action" == *"i"* ]]; then
  clear
  printf "|==Editing==|\n"
  #Echoes files inside of files
  for item in "${files[@]}"; do
    printf "$item\n"
  done
  read -p "=>" input

  for file in ~/dev/bashscripts/*.sh; do
    if [[ "$file" == *"$input"* ]]; then
      cut
      printf "Editing $sfile\n"
      clear
      exec nvim $file
    fi
  done

elif [[ "$action" == *"q"* ]]; then
  clear
  exit
fi








