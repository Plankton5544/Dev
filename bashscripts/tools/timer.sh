#!/bin/bash
echo "##### Welcome To Timer #####"
echo "Please Enter Timer Seconds As Only The Number:"
read seconds
echo "### $seconds Seconds Confirmed. ###"
timer=0

while [ "$timer" -lt "$seconds" ]; do
	echo "$timer"
	((timer++))
	sleep 2
done
if [ "$timer" -eq "$seconds" ]; then

echo "####PRESS CTRL C TO STOP NOW#####" & sleep 3	
       	yes "!TIMER!"
fi
