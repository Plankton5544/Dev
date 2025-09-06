#!/bin/bash

###########
#Constants#
###########
vr=12 #<--- Defines how persuasive ynow 1/not 2/most 2</least
horscont=3 #<--- Defines total horses (mostly rigid honestly mess things up
bet=0 #Just a redefined var
inter=0.1 #<--- Defines the refresh rate of screen, faster makes the game faster, but looks odd, and slower is just ugly but easily see each frame...
height=9 #<--- Defines the height of grid could change but its wonky... and its more than shown lol... for 9 its 12 
width=20 #<--- Defines the length of track, my device 85 is total and 170 is two lines, better at shorter races like 30...
end=0 #Just a redefined var
#1x pos#
int=$((height / $horscont))
h1x=0
h1y=$int 
#2x pos#
h2x=0
h2y=$((int + int ))
#3x pos#
h3x=0
h3y=$((int + int + int ))
height=$((height + int + 1))
#######

#names for horses below
names=("jim" "horse" "bob" "STEVE" "rick" "roll" "Grass" "bill" "flame" "fast")
abnme=("JM"  "HR"    "BB"  "SV"    "RK"   "RL"   "GR"    "BL"   "FM"    "FS"  )
###########

echo "###############################"
echo "# Welcome To The Horsey House #"
echo "###############################"

##############################
# Function For Random Moving #
##############################
move() {
mv=$(( RANDOM  % 3 + 1))
rg=$(( RANDOM  % $vr + 1))
if [ "$rg" = "2" ]; then
  if [ "$mv" = "$bet" ]; then
    mv=$(( RANDOM % 3 + 1))
  fi
fi
case $mv in
  "1") ((h1x++))    ;;
  "2") ((h2x++))    ;;
  "3") ((h3x++))    ;;
esac
}
##############################


#############################
# Function For Horse Naming #
#############################
nme() {
ph1=$(( RANDOM % ${#names[@]} ))
  h1="${names[$ph1]}"
  h1b="${abnme[$ph1]}"
ph2=$(( RANDOM % ${#names[@]} ))
  h2="${names[$ph2]}"
  h2b="${abnme[$ph2]}"
  if [ "$ph2" = "$ph1" ]; then
ph2=$(( RANDOM % ${#names[@]} ))
  h2="${names[$ph2]}"
  h2b="${abnme[$ph2]}"
  fi
ph3=$(( RANDOM % ${#names[@]} ))
  h3="${names[$ph3]}"
  h3b="${abnme[$ph3]}"
  if [ "$ph1" = "$ph3" ]; then
ph3=$(( RANDOM % ${#names[@]} ))
  h3="${names[$ph3]}"
  h3b="${abnme[$ph3]}"
elif [ "$ph2" = "$ph3" ]; then
ph3=$(( RANDOM % ${#names[@]} ))
  h3="${names[$ph3]}"
  h3b="${abnme[$ph3]}"
elif [ "$ph1" = "$ph2" ]; then
ph2=$(( RANDOM % ${#names[@]} ))
  h2="${names[$ph2]}"
  h2b="${abnme[$ph2]}"
  fi
}
#############################

####################################
# Function For Screen Drawing Etc. #
####################################
drw() {
  sleep $inter
  hp=0
  clear
  while [ "$hp" != "$height" ]; do
     lp=0 #<-- I'm unsure how this helps it work but it does
     while [ "$lp" != "$width" ]; do
         if [ "$lp" = "$h1x" ] && [ "$hp" = "$h1y" ]; then
           echo -n "$h1b"
         elif [ "$lp" = "$h2x" ] && [ "$hp" = "$h2y" ]; then
           echo -n "$h2b"
         elif [ "$lp" = "$h3x" ]  && [ "$hp" = "$h3y" ]; then
           echo -n "$h3b"
         else
           echo -n ". "
         fi
     ((lp++))
     done
     ((hp++))
     echo ""
  done
}
####################################


nme
sleep 2
clear
echo "Our Horses..."
sleep 1.5
echo "#################################
### $h1/$h1b, $h2/$h2b, $h3/$h3b ###
#################################"
sleep 0.69
echo "Use Full Name Please"
sleep 0.25
read -p "BET=>" bet
    oldbet=$bet
 if [ "$bet" = "$h1" ]; then
    bet=1
 elif [ "$bet" = "$h2" ]; then
    bet=2 
 elif [ "$bet" = "$h3" ]; then
    bet=3
 elif [ "$bet" = "q" ]; then
 end=1
 fi
    echo " YOU BET,  $oldbet"

while [ "$end" = "0" ]; do
drw
move
      if [ "$h1x" = "$width" ]; then
      end=1
      wi=$h1
      win=1
      elif [ "$h2x" = "$width" ]; then 
      end=1
      wi=$h2
      win=2
      elif [ "$h3x" = "$width" ]; then
      end=1
      wi=$h3
      win=3
      fi
done
echo "The Winner Was.."
sleep 1.5
echo $wi

if [ "$bet" = "$win" ]; then
  echo "YOU'VE WON"
else
  echo "YOU LOST"
fi
echo
echo "You bet, $oldbet"
echo "Out Of, $h1/$h1b $h2/$h2b, $h3/$h3b"
