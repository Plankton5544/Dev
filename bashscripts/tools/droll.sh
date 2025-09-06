#!/bin/bash
echo "#### Welcome To Die Roller ####"
echo "###      Defaults to d20    ###"
echo "##   Example d10, d5, d100   ##"
echo "
ENTER COMPLEXITY:"

read complexityog

#Below removes the d prefix to the desired total outcome
complexity=${complexityog#d}
if [ -z "$complexityog" ]; then 	
	complexity=20
fi

roll=$(( RANDOM % $complexity ))

echo "YOU ROLLED..."
sleep 2
echo $roll
echo "

Clear? (Y/n)"
read clear
if [ -z "$clear" ]; then
	clear
fi

