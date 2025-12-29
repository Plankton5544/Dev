#!/bin/bash
#Hides Cursor
printf "\x1b[?25l"

####################
#Starting Constants#
####################
inter=0.1      #<--- Sets The Refresh Rate
width=20       #<--- Sets Pixl Width
height=20      #<--- Sets Pixl Length
plyrx=10       #<--- Determine The Starting X Position For Player
plyry=10       #<--- Determine The Starting Y Position For Player
end=0          #<--- Sets The End Of Stop To Continue (1 For End, 0 For Run)
background="." #<--- Sets The Background Character
snake="S"      #<--- Sets The Snake Character
length=0
####################



#Title Echo And Read Difficulty
echo "###########################"
echo "#### WELCOME TO SNAKE #####"
echo "###########################"
diff="$1"

#User Prep Echos
echo "##   Move With WASD   ##"
sleep 1
echo "3.."
sleep 0.25
echo "2.."
sleep 0.25
echo "1.."
sleep 0.25

#If Statements For Difficulty
if [[ "$diff" -gt 5 ]]; then
  inter=0.075
  height=15
  width=15
elif [[ "$diff" -gt 9 ]]; then
  inter=0.069
  height=10
  width=10
elif [[ "$diff" = "MAX" ]]; then
  height=3
  width=10
  plyrx=0
  plyry=2
elif [[ "$diff" = "invis" ]]; then
  background=" "
  snake="]"
elif [[ "$diff" = q ]]; then
end=1
fi


###################
#Function For Food#
###################
fd() {
  fdx=$(( RANDOM % $width + 1 ))
  fdy=$(( RANDOM % $height + 1 ))
}
###################

fd

######################
#Function For Display#
######################
clear
drw() {
  printf "\033[0;0H"

  # TODO FIX THESE
  ate_food=0
  if (( plyrx == fdx && plyry == fdy )); then
    ate_food=1
  fi

  # insert new head at front
  trail=( "$plyrx $plyry" "${trail[@]}" )

  # if food NOT eaten, remove tail
  if (( ate_food == 0 )); then
    unset 'trail[-1]'
  else
    fd   # spawn new food
  fi
}
######################

dirx=1
diry=0
trail=()

####################
#Main Loop With End#
####################
while [ $end -eq 0 ]; do
  read -s -t $inter -n1 move
  if [ -n "$move" ]; then
    case $move in
      "w") if [ $diry -eq 0 ]; then
        dirx=0
        diry=-1
        fi ;;
      "s") if [ $diry -eq 0 ]; then
        dirx=0
        diry=1
        fi ;;
      "d") if [ $dirx -eq 0 ]; then
        dirx=1
        diry=0
        fi ;;
      "a") if [ $dirx -eq 0 ]; then
        dirx=-1
        diry=0
        fi ;;
      "q") end=1 ;;
    esac
  fi
  plyry=$((plyry + diry))
  plyrx=$((plyrx + dirx))
  if [ $plyrx -gt $width ] || [ $plyrx -lt 1 ] || [ $plyry -gt $height ] || [ $plyry -lt 1 ]; then
  end=1
  fi
  drw
done
####################

#Game Ending Screen#
echo "GAME OVER!"
echo "Tail Length, $tail"
###################
