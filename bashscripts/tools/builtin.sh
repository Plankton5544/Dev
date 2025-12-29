#!/bin/bash
# Script to analyze Bash script files, counting known, unknown,
# and external commands, reporting them at the end.

# Usage: ./script_name.sh <script_file> <--debug>
declare -a external_commands=("jq" "curl" "wget" "git" "awk" "sed" "grep" "bc" "trap" "dialog" "PSTools" "tmux" "screen" "clear" "sleep")
debug=0 ext=0 unknown=0 known=0
if [[ $2 == "--debug" ]]; then
  debug=1
fi

rm_prefix() {
  local input="$1"
  # Remove leading spaces and tabs
  while [[ "$input" =~ ^[[:space:]] ]]; do
    input=${input##[[:space:]]}
  done
  echo $input
}

env_check() {
  local input="$1"
  if [[ ($input == *"bin"* && ($input == *"bash"* || $input == *"env"* )) || $input == *'#!'* ]]; then
    return 0
  else
    return 1
  fi
}

exit_check() {
  local input="$1"
  if [[ $input == *"exit "* ]]; then
    return 0
  else
    return 1
  fi
}

if_check() {
  local input="$1"
  if [[ $input == *"if "* || $input == *"fi "* ]]; then
    return 0
  else
    return 1
  fi
}

for_check() {
  local input="$1"
  if [[ ($input == *"for"* && ($input == *'{'* || $input == *'('* || $input == *')'* )) || $input == *"done"* ]]; then
    return 0
  else
    return 1
  fi
}

def_check() {
  local input="$1"
  if [[ $input == *"="* && $input != *"=="* ]]; then
    return 0
  else
    return 1
  fi
}

fn_check() {
  local input="$1"
  if [[ $input == *"()"* && $input == *"{"* ]]; then
    return 0
  else
    return 1
  fi
}

comms_check() {
  local input="$1"
  if [[ ${input:0:1} == '#' ]]; then
    return 0
  else
    return 1
  fi
}

case_check() {
  local input="$1"
  if [[ $input == *"esac"* || ($input == *'"'* && $input == *')'* || $input == *";;"*) ]]; then
    return 0
  else
    return 1
  fi
}

incr_check() {
  local input="$1"
  if [[ ($input == *"(("* && $input == *"))"*) && ($input == *"++"* || $input == *"--"*) ]]; then
    return 0
  else
    return 1
  fi
}

ext_check() {
  local input="$1"
  for cmd in "${external_commands[@]}"; do
    if [[ $input == *"$cmd"* ]]; then
      return 0
    else
      return 1
    fi
  done
}

known() {
  echo $line
  ((known++))
}
unknown() {
  local flag=$1
  if [[ $flag == "-d" ]]; then
    echo "line: $line"
  fi
    echo "Unknown"
  ((unknown++))
}
external() {
  local flag=$1
  if [[ $flag == "-d" ]]; then
    echo "line: $line"
  fi
  echo "!!!!EXTERNAL!!!!"
  ((ext++))
}

debug() {
  local fn=$1
  if [[ $debug -eq 1 ]]; then
    if type "$fn" &>/dev/null; then
      $fn "-d"
    else
      echo "Debug: $fn function does not exist."
    fi
  fi
}


IFS=$'\n'
while read -r line; do
  if [ -n "$line" ]; then

    line=$(rm_prefix "$line")
    word=${line%% *}

    if ext_check $line; then
      debug "external"
    elif [ -z $(type -t "$word") ]; then

      if env_check $word; then
        debug "known"
      elif fn_check $line; then
        debug "known"
      elif for_check $line; then
        debug "known"
      elif exit_check $line; then
        debug "known"
      elif case_check $line; then
        debug "known"
      elif incr_check $line; then
        debug "known"
      elif def_check $line; then
        debug "known"
      elif if_check $word; then
        debug "known"
      elif comms_check $word; then
        debug "known"
      else
        if !(ext_check $line); then
          debug "unknown"
        fi
      fi
    fi
  fi
  done < "$1"
unset IFS
if [[ -n $ext || -n $unknown ]]; then
  echo "External Calls: $ext"
  echo "Unknown Calls: $unknown"
elif [[ -z $known ]]; then
  echo "No Lines Detected!"
fi
