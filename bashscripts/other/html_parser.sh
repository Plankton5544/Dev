#!/bin/bash
#set -x
shopt -s nocasematch
buffer=()
buffer2=()
declare is_title is_header is_par is_bold is_italic is_list is_code is_block_quote is_link is_hr is_br

# Color and formatting definitions
TITLE_COLOR="\033[1;36m"      # Bright cyan
HEADING_COLOR="\033[1;33m"    # Yellow
LINK_COLOR="\033[4;34m"       # Blue underlined
BOLD_FORMAT="\033[1m"         # Bold
ITALIC_FORMAT="\033[3m"       # Italic
CODE_COLOR="\033[90m"         # Gray
RESET="\033[0m"               # Reset formatting

# Echo functions for different HTML elements
title_echo() {
    printf "${TITLE_COLOR}%s${RESET}\n" "$1"
}

heading_echo() {
    local text="$1"
    local level="$2"
    local indent=""

    # Create indentation based on heading level
    for ((i=0; i<level; i++)); do
        indent+=" "
    done

    printf "${HEADING_COLOR}%s%s${RESET}\n" "$indent" "$text"
}

link_echo() {
    local text="$1"
    #TODO Implement Url parsing and then output differently
    printf "${LINK_COLOR}%s${RESET}\n" "$text"
}

bold_echo() {
    printf "${BOLD_FORMAT}%s${RESET}\n" "$1"
}

italic_echo() {
    printf "${ITALIC_FORMAT}%s${RESET}\n" "$1"
}

code_echo() {
    printf "${CODE_COLOR}%s${RESET}\n" "$1"
}

quote_echo() {
    printf "  > %s\n" "$1"
}

list_item_echo() {
    printf "  • %s\n" "$1"
}

hr_echo() {
    printf "────────────────────────────────────────\n"
}

# Combination function for paragraph with nested formatting
paragraph_with_formatting() {
    local text="$1"
    local is_bold="$3"
    local is_italic="$4"
    local is_link="$5"

    # Build format string
    local format=""
    local reset_format=""

    if [[ $is_bold == 1 ]]; then
        format+="$BOLD_FORMAT"
        reset_format="$RESET$reset_format"
    fi

    if [[ $is_italic == 1 ]]; then
        format+="$ITALIC_FORMAT"
        reset_format="$RESET$reset_format"
    fi

    if [[ $is_link == 1 ]]; then
        format+="$LINK_COLOR"
        reset_format="$RESET$reset_format"
    fi

    printf "%s%s%s\n" "$format" "$text" "$reset_format"
}






remove_substring() {
    local original_string="$1"
    local substring="$2"

    # Use parameter expansion to remove all occurrences of the substring
    local modified_string="${original_string//$substring/}"

    #echo "$modified_string"
}

ltrim() {
  temp="${1#"${1%%[![:space:]]*}"}";
}

rtrim() {
  temp="${1%"${1##*[![:space:]]}"}";
}

output_check() {
  local text=$1
  # 1. STRUCTURAL CONTAINERS (highest priority)
  if [[ $is_title == 1 ]]; then
    remove_substring "$text" "title"
    remove_substring "$text" "title"
    remove_substring "$text" "<"
    remove_substring "$text" ">"
    title_echo "$text"
    is_title=0
  elif [[ $is_header == 1 ]]; then
    remove_substring "$text" "<h$heading_level"
    remove_substring "$text" "</h$heading_level"
    heading_echo "$text" "$heading_level"
    is_header=0
    header_level=0
  elif [[ $is_code == 1 || $in_pre == 1 ]]; then
    remove_substring "$text" "<code"
    remove_substring "$text" "/code"
    remove_substring "$text" "<pre"
    remove_substring "$text" "/pre"
    code_echo "$text"
    is_code=0
  elif [[ $is_block_quote == 1 ]]; then
    #TODO FIX THIS!!
    #quote_echo "$text"
    is_block_quote=0

    # 2. LIST HANDLING
  elif [[ $is_list == 1 ]]; then
    #TODO FIXTHIS!!
   # remove_substring "$text" "<li"
   # remove_substring "$text" "/li"
   # list_item_echo "$text"
    is_list=0

    # 3. PARAGRAPH WITH NESTED FORMATTING
  elif [[ $is_par == 1 ]]; then
    # Apply inline formatting within paragraph
    if [[ $is_link == 1 ]]; then
      link_echo "$text"
      is_link=0
    elif [[ $is_bold == 1 ]]; then
      #TODO FIX THIS
      #bold_echo "$text"
      is_bold=0
    elif [[ $is_italic == 1 ]]; then
      #  TODO FIX THIS
      #  italic_echo "$text"
      is_italic=0
    else
      #TODO FIX THIS
      #echo "$text"  # plain paragraph text
      is_par=0
    fi

    # 4. STANDALONE INLINE ELEMENTS (outside paragraphs)
  elif [[ $is_link == 1 ]]; then
    link_echo "$text" "$current_url"
      is_link=0
  elif [[ $is_bold == 1 ]]; then
    #TODO FIX THIS
    #bold_echo "$text"
      is_bold=0
  elif [[ $is_italic == 1 ]]; then
    #TODO FIX THIS
    #italic_echo "$text"
      is_italic=0

    # 5. SPECIAL CASES
  elif [[ $is_hr == 1 ]]; then
    hr_echo
    is_hr=0
  elif [[ $is_br == 1 ]]; then
    echo  # blank line
    is_br=0

    #   TODO FIX THIS (If i want this?)
    #   # 6. DEFAULT
    # else
    #   if [[ "$text" != *"<"* && "$text" != *">"* && "$text" != *"/"* ]]; then
    #     echo "$text"  # plain text
    #   fi
  fi
}

tag_identification() {
  case "$1" in
    *"<title"*)
      is_title=1
      ;;

    *"<h"*)
      for i in {1..10}; do
        if [[ "$1" == "<h$i" ]]; then
          is_header=1
          heading_level=$i
        fi
      done
      ;;

    *"<p"*)
      is_par=1
      ;;

    *"<strong"*|*"<b"*)
      is_bold=1
      ;;

      #TODO It could be the ** causing weird identification of italics etc?
    *"<em"*|*"<i"*)
      is_italic=1
      ;;

    *"<a"*)
      is_link=1
      ;;

    *"ul"*|*"ol"*)
      is_list=1
      ;;

    *"<code"*|*"<pre"*)
      is_code=1
      ;;

    *"blockquote"*)
      is_block_quote=1
      ;;

    *"hr"*)
      is_hr=1
      output_check "$1"
      ;;

    *"br"*)
      is_br=1
      output_check "$1"
      ;;
    *"<!--"*)
      #skip
      ;;

    *)
      output_check "$1"
      ;;

  esac
}

content=""
while IFS= read -r line; do
  content+="$line"
done < "$1"


temp="$content"
while [[ "$temp" == *">"* ]]; do
    ltrim "$temp"
    rtrim "$temp"
    before="${temp%%>*}" # Everything before first > (<title)
    buffer+=("$before")

    temp="${temp#*>}"   # Everything after first > (text</title)
done

for asd in "${buffer[@]}"; do
  if [[ "$asd" == *"</"* ]]; then
    before="${asd%%<*}"
    asd="${asd#*<}"
    buffer2+=("$before")
    buffer2+=("$asd")
  else
    buffer2+=("$asd")
  fi
done





for item in "${buffer2[@]}"; do
  tag_identification "$item"
done

