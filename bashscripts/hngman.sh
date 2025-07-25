#!/bin/bash

wordlist=("sigma" "goon" "gooner" "alpha" "gamma" "beta" "rizzler" "ohio" "arch" "emote" "chickenjockey" "flint" "steel" "buckchuckets" "diamond" "armor" "child" "yearn" "mines" "miner" "calc" "calculator" "nether" "minecraft" "technoblade" "orphans" "oh" "skeet" "boots" "swiftness" "potato" "words" "ozzy" "jmao" "ryky" "peyto" "linux")


rando=$(( RANDOM % ${#wordlist[@]} ))
	sword="${wordlist[$rando]}"

length=${#sword}

echo "##### Welcome To #####"
echo "####    HANGMAN   ####"
sleep 1


echo "Your Slang Is $length, letters long."

case $length in
	"1") echo " _ " ;;
	"2") echo " _ _ " ;;
	"3") echo " _ _ _ " ;;
	"4") echo " _ _ _ _ " ;;
	"5") echo " _ _ _ _ _ " ;;
	"6") echo " _ _ _ _ _ _ " ;;
	"7") echo " _ _ _ _ _ _ _ " ;;
	"8") echo " _ _ _ _ _ _ _ _ " ;;
	"9") echo " _ _ _ _ _ _ _ _ _ " ;;
	"10")echo " _ _ _ _ _ _ _ _ _ _ " ;;
esac

echo "Please Enter a letter geuss:"
read geuss1

if [[ "$sword" == *"$geuss1"* ]]; then
	echo "The letter, $geuss1 exists in the word"
else
	echo "The letter $guess1 does not exist in the word"

	echo "                                      $sword $length"

