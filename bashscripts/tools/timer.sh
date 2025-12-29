#!/bin/bash
echo "##### Welcome To Timer #####"
echo "Please Enter Timer Seconds As Only The Number:"
read seconds
echo "### $seconds Seconds Confirmed. ###"
timer=0

while [[ "$timer" < "$seconds" ]]; do
  echo "$timer"
  ((timer++))
  sleep 2
done
if [[ "$timer" == "$seconds" ]]; then
  echo "####PRESS CTRL C TO STOP NOW#####" & sleep 3
  while [[ 1 -eq 1 ]]; do
    yes "!TIMER!"
  done
fi
