#!/bin/bash



calculate() {
	case $op in
		"+") result=$((num1 + num2))	;;
		"-") result=$((num1 - num2))	;;
		"*") result=$((num1 * num2))	;;
	*)	echo "!ERROR!"; return ;;
	esac	
	echo "Result: $result"
}

while true; do
	echo "Please Enter First Number Or 'q' To Quit:"
	read num1
		if [[ "$num1" == "q" ]]; then break; fi

	echo "Please Enter Operation:"
	read op

	echo "Please Enter Second Number"
	read num2

	calculate
done
echo "Bye!"
