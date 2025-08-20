#!/bin/bash
width=20
height=20
plyrx=10
plyry=10
end=0
printf "\x1b[?25l"
######################
#Function for display#
######################
#function
drw() {
  hp=1
printf "\033[1;1H"

while [ "$hp" -le "$height" ]; do
  lp=1
  while [ "$lp" -le "$width" ]; do
    if [ "$lp" -eq "$plyrx" ] && [ "$hp" -eq "$plyry" ]; then
    echo -n "P " #<----Prints P or character (for now)
    else
      echo -n "  "
    fi
      ((lp++))
  done
  echo
  ((hp++))
done

}
######################





#Prompt for Start
echo "### WELCOME TO (INSERT NAME) ###"
echo "##       Move With WASD       ##"

sleep 2
while [ $end -eq 0 ]; do
  drw

  read -s -n1 move

case $move in
  "w") ((plyry--)) ;;
  "s") ((plyry++)) ;;
  "a") ((plyrx--)) ;;
  "d") ((plyrx++)) ;;
esac

### THESE ARE ENDING FOR X & Y, basicaly ifs under or over height/width or 0
  if [ $move = "q" ]; then
   end=1
  fi

  if [ $plyry -gt "$height" ]; then
   end=1
  fi

  if [ $plyrx -gt $width ]; then
  end=1
  fi

  if [ $plyrx -lt 1 ]; then
  end=1
  fi

  if [ $plyry -lt 1 ]; then
  end=1
  fi

done


