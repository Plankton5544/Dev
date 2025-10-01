#/bin/bash
COLUMNS=$1
LINES=$2
width=10
height=10
declare i
true=1

# INVIS CURSOR
echo -e "\e[?25l"
#

player=($((COLUMNS / 2)) $((LINES / 2)))

if [[ -z $COLUMNS ]]; then
  echo "Please provide \$COLUMNS and \$LINES arguments when running the script.
  e.g. 'bash "file_name" <\$COLUMNS> <\$LINES>'"
  exit
elif [[ -z $LINES ]]; then
  echo "Please provide $COLUMNS and $LINES arguments when running the script.
  e.g. 'bash "file_name" <\$COLUMNS> <\$LINES>'"
  exit
fi

save_screen() {
  echo -e "\e[?47h"
}
restore_screen() {
  echo -e "\e[?47l"
}

input_processing() {
  local input=$1
  if [[ $input == "q" ]]; then
    true=0
  fi
}

border_disp() {
  # MOVE CURSOR HOME
  clear
  #

  local y=1
  until [[ $y -eq $LINES ]]; do
    local x=0
    until [[ $x -eq $COLUMNS ]]; do
      if [[ "${player[1]}" -eq $x || "${player[2]}" -eq $y ]]; then
        echo -n "P"
      elif [[ $x -eq 0 || $x -eq $((COLUMNS - 1)) ]]; then
        echo -n "|"
      elif [[ $y -eq 1 || $y -eq $((LINES- 1)) ]]; then
        echo -n "-"
      elif [[ $input == "e" ]]; then
        echo -n "."
      else
        echo -n " "
      fi
      ((x++))
    done
    echo
    ((y++))
  done
}




clear
while [[ $true -eq 1 ]]; do
  read -s -t 0.5 -n1 input

  border_disp "$Input" "$1"
  input_processing "$input"
  ((i++))
done


echo -e "\e[?1049l"
echo -e "\e[?25h"
