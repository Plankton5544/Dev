#!/bin/bash

## Author: Plankton5544
## DISCRETION!!! AI was used, I made this to check other scripts
### Date Of Creation: August 15 2025
# Idea:
# Features:
#
#
#
##

if [ $# -eq 0 ]; then
    echo "Usage: $0 <string> [options]"
    exit 1
fi

# Get the first argument (Required String)
input="$1"
shift  # Remove the first argument so getopts only sees the options

# Now process the options
while getopts "::he" opt; do
    case $opt in
        e)
          extra=1;;
        h)
          echo "Usage: $0
          echo "Note:
          echo "Options: "
          exit 1
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done



if [ -z "$input" ]; then
  echo "ERROR! MISSING FILE"
  exit 1
fi

echo "|==Processing=File==|"
while IFS= read -r line; do
    # Process the 'line' variable here
    # Example: Extract the first word using parameter expansion
    first_word="${line%% *}"
    output=$(type -t $first_word)
    case $output in
      "alias")
        if [ "$extra" == 1 ]; then
        echo "$first_word=alias"
      else
        echo "alias"
        fi ;;
      "keyword")
        if [ "$extra" == 1 ]; then
        echo "$first_word=keyword"
      else
        echo "keyword"
        fi ;;
      "builtin")
        if [ "$extra" == 1 ]; then
        echo "$first_word=builtin"
      else
        echo "builtin"
        fi ;;
      "file")
        external=1
        echo "$first_word     !file!"
        ;;
    esac


done <  $input

if [[ "$external" == 1 ]]; then
  echo -e "\033[31mPotential External Commands Used!\033[0m"
else
  echo -e "\033[32mClear! No Detected External Commands Used\033[0m"
fi



# Unfinished need to implement:
# better detections etc idk?
#
#
#
#
#
#
