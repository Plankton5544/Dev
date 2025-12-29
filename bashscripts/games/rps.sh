#!/bin/bash
echo "##### ENTER EITHER #####
##ROCK PAPER SKIZZERS##"
read usr
cp=$((RANDOM % 3 + 1))
#3 is Rock 2 is Paper 1 is Skizzers

if [ "$cp" -eq 3 ] && [ "$usr" = "PAPER" ]; then
	outcome=1
elif [ "$cp" -eq 3 ] && [ "$usr" = "SKIZZERS" ]; then
	outcome=0
elif [ "$cp" -eq 3 ] && [ "$usr" = "ROCK" ]; then
	outcome=3

elif [ "$cp" -eq 2 ] && [ "$usr" = "SKIZZERS" ]; then
	outcome=1
elif [ "$cp" -eq 2 ] && [ "$usr" = "PAPER" ]; then
	outcome=3
elif [ "$cp" -eq 2 ] && [ "$usr" = "ROCK" ]; then
	outcome=0

elif [ "$cp" -eq 1 ] && [ "$usr" = "SKIZZERS" ]; then
	outcome=3
elif [ "$cp" -eq 1 ] && [ "$usr" = "PAPER" ]; then
	outcome=0
elif [ "$cp" -eq 1 ] && [ "$usr" = "ROCK" ]; then
	outcome=1
else
	echo "ERROR OCCURED" && outcome=4 && cp=4
fi
echo "##### OUTCOME #####"
sleep 3
case "$outcome" in
	"1") echo "WINNER :)" & sleep 2	;;
	"0") echo "LOST :(" & sleep 2	;;
	"3") echo "TIE :|" & sleep 2	;;
	"4") echo "ERROR!"		;;
esac
case "$cp" in
	"1") echo "CP CHOSE SKIZZERS"	;;
	"2") echo "CP CHOSE PAPER"	;;
	"3") echo "CP CHOSE ROCK"	;;
	"4") echo "ERROR!"		;;
esac
echo "Clear? (y/n)"
read clear
if [ "$clear" = "y" ]; then
  clear
fi
