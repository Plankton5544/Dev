#!/bin/bash
#set -x
shopt -s nocasematch
par=0
            i=1
temp=
buffer=()

title_echo() { printf "\033[1;36m%s\033[0m\n" "$1"; }  # Bright cyan for titles
heading_echo() { printf "\033[1;33m%s\033[0m\n" "$1"; } # Yellow for headings
link_echo() { printf "\033[4;34m%s\033[0m\n" "$1"; }    # Blue underlined for links

secho() {
  printf "\033[31m%s\033[0m\n" "$1"
}
pecho() {
  printf "\033[32m%s\033[0m\n" "$1"
}

remove_substring() {
    local original_string="$1"
    local substring="$2"

    # Use parameter expansion to remove all occurrences of the substring
    local modified_string="${original_string//$substring/}"

    echo "$modified_string"
}

link_handle() {
  local out="$1"
  out=$(remove_substring "$out" "<p>")
  out=$(remove_substring "$out" "</p>")
  out=$(remove_substring "$out" "<a ")
  out=$(remove_substring "$out" "<a>")
  out=$(remove_substring "$out" "</a>")
  out=$(remove_substring "$out" "href=")
  link_echo "$out"
}

bold_handle() {
  local out="$1"
  out=$(remove_substring "$out" "<p>")
  out=$(remove_substring "$out" "</p>")
  out=$(remove_substring "$out" "<strong>")
  out=$(remove_substring "$out" "</strong>")
  out=$(remove_substring "$out" "<b>")
  out=$(remove_substring "$out" "</b>")
  printf "\033[1m%s\033[0m\n" "$out"  # Bold text
}

italic_handle() {
  local out="$1"
  out=$(remove_substring "$out" "<p>")
  out=$(remove_substring "$out" "</p>")
  out=$(remove_substring "$out" "<em>")
  out=$(remove_substring "$out" "</em>")
  out=$(remove_substring "$out" "<i>")
  out=$(remove_substring "$out" "</i>")
  printf "\033[3m%s\033[0m\n" "$out"  # Italic text
}


special_interpretation() {
  local out="$1"
  if [[ $par -ne 1 ]]; then
    case $out in
      *"<title>"*)
        out=$(remove_substring "$1" "<title>")
        out=$(remove_substring "$out" "</title>")
        title_echo "$out"
        ;;

      *"<h"*)
        #Change the 10 to max if want more variability
        for i in {1..10}; do
          if [[ "$out" == *"<h$i>"* ]]; then
            prefix=""
            out=$(remove_substring "$out" "<h$i>")
            out=$(remove_substring "$out" "</h$i>")

            for ((k=0; k<i; k++)); do
              prefix+=" "
            done
            out=${prefix}$out
            heading_echo "$out"
          fi
        done;;

      *"<p>"*)
        if [[ "$out" != *"<a"* ]]; then
          if [[ "$out" != *"</p>"* ]]; then
            par=1
          else
            par=0
          fi
          out=$(remove_substring "$out" "<p>")
          out=$(remove_substring "$out" "</p>")
          echo $out
        elif [[ "$out" == *"<strong>"* || "$out" == *"<b>"* ]]; then
          bold_handle "$out"
        elif [[ "$out" == *"<em>"* || "$out" == *"<i>"*  ]]; then
          italic_handle "$out"
        else
          link_handle "$out"
        fi
        secho $par
        ;;

      *"<strong>"*|*"<b>"*)
        bold_handle "$out"
        ;;

      *"<em>"*|*"<i>"*)
        italic_handle "$out"
        ;;

      *"<a>"*)
        link_handle "$out"
        ;;


      *"<img"*);;
      *"<table"*);;
    esac
  else
    case $out in

      *"</p>"*)
        if [[ "$out" != *"<a"* ]]; then
          out=$(remove_substring "$out" "<p>")
          out=$(remove_substring "$out" "</p>")
          echo $out
        elif [[ "$out" == *"<strong>"* || "$out" == *"<b>"* ]]; then
          bold_handle "$out"
        elif [[ "$out" == *"<em>"* || "$out" == *"<i>"*  ]]; then
          italic_handle "$out"
        else
          link_handle "$out"
        fi
        par=0
        echo $par
          ;;


      *"<ul>"*|*"<ol>"*)
        echo "List:"
        ;;

      *"<li>"*)
        out=$(remove_substring "$out" "<li>")
        out=$(remove_substring "$out" "</li>")
        echo "  • $out"  # Bullet point
        ;;

      *"<code>"*|*"<pre>"*)
        out=$(remove_substring "$out" "<code>")
        out=$(remove_substring "$out" "</code>")
        out=$(remove_substring "$out" "<pre>")
        out=$(remove_substring "$out" "</pre>")
        printf "\033[90m%s\033[0m\n" "$out"  # Gray for code
        ;;

      *"<blockquote>"*)
        out=$(remove_substring "$out" "<blockquote>")
        out=$(remove_substring "$out" "</blockquote>")
        echo "  > $out"  # Indented quote
        ;;

      *"<hr"*)
        echo "────────────────────"  # Horizontal rule
        ;;

      *)
        if [[ "$out" != *"<p>"* && "$1" != *"</p>"* ]]; then
          if [[ "$out" != *"<a"* ]]; then
            echo $out
          elif [[ "$out" == *"<strong>"* || "$out" == *"<b>"* ]]; then
            bold_handle "$out"
          elif [[ "$out" == *"<em>"* || "$out" == *"<i>"*  ]]; then
            italic_handle "$out"
          else
            link_handle "$out"
          fi
        fi
        ;;

    esac
  fi
}




ltrim() {
  temp="${1#"${1%%[![:space:]]*}"}";
}


rtrim() {
  temp="${1%"${1##*[![:space:]]}"}";
}






IFS=$'\n'
while read -r -s field1; do
  ltrim "$field1"
  rtrim "$temp"

  # Only process lines that contain an opening bracket
#    pecho "$temp"
    buffer+=("$temp")
done < "$1"


secho "Processing: $(basename "$1")"
secho "|===========|"
echo #blank

for item in "${buffer[@]}"; do
  case "$item" in
    *"<!"*)
     # if [[ "$item" == *"html>"* ]]; then
     #   echo $item
     #   secho "interpreting as html*"
     # fi
      ;;


    *"<html"*)
      # echo $item
      #secho "opening html*"
      ;;

    *"<head>"*)
     # echo $item
     # secho "opening head*"
     ;;

    "body")
     # echo $item
     # secho "opening body*"
      ;;


    *"</html"*) #secho "closing html*"
      ;;
    *"/head"*) #secho "closing head*"
      ;;
    *"/body"*) #secho "closing body*"
      ;;


    *"meta"*|*"style"*)
     # echo $item
     # secho "other*"
      ;;
    *"div"*)
      #echo $item
      #secho "other*"
      ;;

    *) special_interpretation "$item" ;;
  esac
done

