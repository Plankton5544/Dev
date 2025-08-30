#!/bin/bash
## author: plankton5544
### date of creation: August 29 2025
# idea: stupid custom langauge interpreter
# Features:
# BASH!
# 2-Dimensional programming!
# 8-Directional Movement!
# Best yet...
# Horrible Implementation!!!
#
#
#
#






understand_bit() {
  case "$bit" in
    ">") i=$((i+2))
      ;;

    "<") ((i--))
      ;;

    "q")
      y=$((y - 1))
      x=$((x - 1))
      if [[ $y -lt $sizey && $x -gt 0 ]]; then
        i=$((y * sizex + x))
      else
        echo "cannot move - continuing normally"
        ((i++))
      fi
      ;;

    "w")
      y=$((y - 1))
      x=$((x + 1))
      if [[ $y -lt $sizey && $x -gt 0 ]]; then
        i=$((y * sizex + x))
      else
        echo "cannot move - continuing normally"
        ((i++))
      fi
      ;;

    "a")
      y=$((y + 1))
      x=$((x - 1))
      if [[ $y -lt $sizey && $x -gt 0 ]]; then
        i=$((y * sizex + x))
      else
        echo "cannot move - continuing normally"
        ((i++))
      fi
      ;;

    "s")
      y=$((y + 1))
      x=$((x + 1))
      if [[ $y -lt $sizey && $x -gt 0 ]]; then
        i=$((y * sizex + x))
      else
        echo "cannot move - continuing normally"
        ((i++))
      fi
      ;;

    "$")
      store=1
      ((i++))
      ;;

    "\\")
      y=$((y + 1))
      if [[ $y -lt $sizey ]]; then
        i=$((y * sizex + x))
      else
        echo "Cannot move down - continuing normally"
        ((i++))
      fi
      ;;

    "/")
      y=$((y - 1))
      if [[ $y -ge 0 ]]; then
        i=$((y * sizex + x))
      else
        echo "  Cannot move down - continuing normally"
        ((i++))
      fi
      ;;

    "+")  memory[$mindex]=$((memory[mindex] + 1))
      ((i++))
      ;;

    "-") memory[$mindex]=$((memory[mindex] - 1))
      ((i++))
      ;;

    "#")
      echo $memory[$mindex]
      ((i++))
      ;;

    "%")
      echo $smemory
      ((i++))
      ;;

    "?")
      if [[ ${memory[$mindex]:-0} -eq 0 ]]; then
        ((i++))
      fi
      ((i++))
      ;;

    ":")
      if [[ ${memory[$mindex]:-0} -gt 0 ]]; then
        ((i++))
      fi
      ((i++))
      ;;

    ";")
      if [[ ${memory[$mindex]:-0} -lt 0 ]]; then
        ((i++))
      fi
      ((i++))
      ;;

    "[")
      if [[ ${memory[$mindex]:-0} -eq 0 ]]; then
        bracket_count=1
        search_pos=$((i+1))
        while [[ $bracket_count -gt 0 && $search_pos -lt ${#oned_file[@]} ]]; do
          case "${oned_file[search_pos]}" in
            "[") ((bracket_count++)) ;;
            "]") ((bracket_count--)) ;;
          esac
          ((search_pos++))
        done
        i=$search_pos
      else
        ((i++))
      fi
      ;;

    "]")
      if [[ ${memory[$mindex]:-0} -ne 0 ]]; then
        bracket_count=1
        search_pos=$((i-1))
        while [[ $bracket_count -gt 0 && $search_pos -ge 0 ]]; do
          case "${oned_file[search_pos]}" in
            "]") ((bracket_count++)) ;;
            "[") ((bracket_count--)) ;;
          esac
          ((search_pos--))
        done
        i=$((search_pos+1))
        echo "Jumped back to loop start: $i"
      else
        ((i++))
      fi
      ;;

    "^")
      read -p "==> " input_val
      memory[$mindex]=$input_val
      ((i++))
      ;;

    "Z")
      smemory=""
      memory=()
      ((i++))
      ;;

    "}")
      ((mindex++))
      ((i++))
      ;;

    "{")
      ((mindex++))
      ((i++))
      ;;

    *)
      ((i++))
      ;;
    esac
  }










#==INITIALS==#
declare -a oned_file
declare -a memory
smemory=""
mindex=0
i=0


#==FILE=HEADER==#
signature=$(dd if="$1" bs=1 count=45 2>/dev/null)
#--integrity-check--#
if [[ $signature != "3.141592653589793238462643383279502884197169x" ]] || [[ -z $1 ]]; then
  echo "FILE .NOT ACCEPTED"
  exit 1
fi
skip=46
#==DIMENSIONS==#
size_x=$(dd if="$1" bs=1 count=2 skip=$skip 2>/dev/null)
sizex="${size_x//x/}"
#--x-check
skip=$((skip+3))
size_y=$(dd if="$1" bs=1 count=2 skip=$skip 2>/dev/null)
sizey="${size_y//x/}"
skip=$((skip+3))
#--y-check

#==1D=ARRAY=FILLING==#
for ((y=0; y<sizey; y++)); do
  for ((x=0; x<sizex; x++)); do
    #--calculate-byte-pos
    byte_position=$((skip + y * sizex + x))
    byte_value=$(dd if="$1" bs=1 count=1 skip=$byte_position 2>/dev/null)
    oned_file+=("$byte_value")
  done
done

#==MAIN=LOOP==#
while [[ $i -lt ${#oned_file[@]} ]]; do
  bit="${oned_file[i]}"
  bit=$(echo -n "$bit" | tr -d '\0\r\n' 2>/dev/null) #<--Remove-any-trailing-whitespace/control-chars
  #-Convert-1D-position-to-2D-coordinates
  x=$((i % sizex))
  y=$((i / sizex))
  #--storage-check
  if [[ $store -gt 0 ]]; then
    smemory+="$bit"
    store=0
  fi

  understand_bit
      done


