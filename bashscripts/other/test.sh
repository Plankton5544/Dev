#!/bin/bash
skip=0
temp=

ltrim() {
  temp="${1#"${1%%[![:space:]]*}"}";
}


rtrim() {
  temp="${1%"${1##*[![:space:]]}"}";
}


element_check() {
echo "test"

}
#<html>
#<head>
#<body>
#(<h1> to <h6>)
#<p>
#<a>
#<img>
#<form>



bytes=$(dd if="$1" bs=1 count=15 2>/dev/null)
if [[ $bytes != "<!DOCTYPE html>" ]]; then
  echo  "ERROR: NO HTML FOUND"
  exit 1
fi


IFS='\'  # Set the delimiter
while read -r -s field1; do
  ltrim $field1
  rtrim $temp

  printf "$temp\n"
done < "$1"


