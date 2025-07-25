#!/bin/bash
#constants for start of the game
#could make customizable?
width=20 #<---Sets pixl width
height=20 #<--- Sets pixl Length
#both pixls determine the *death barrier*
plyrx=10 #<--- determine the starting x position for player (or p)
plyry=10 #<--- determine the starting y position for player (or p)
end=0 #<--- sets the end of stop to continue (1 for end, 0 for run)

######################
#Function for display#
######################
#function
drw() {
  #sets hp garuntees proper amount of display?...
  hp=1
  #clears screen each frame
  clear
  #Containg while statement for height and loops the inner while
  #basically says if out tempvar!=height then loop
while [ "$hp" -le "$height" ]; do

  lp=1 #<---same as last set var

  #inner while states that tempvar2!=width then do inner
  while [ "$lp" -le "$width" ]; do

    if [ "$lp" -eq "$plyrx" ] && [ "$hp" -eq "$plyry" ]; then
    #determines if each time we print a . on screen if it -eq players x&y if so
    echo -n "P " #<----Prints P or character (for now)

    else #<---Prints tradional *empty* pixl
      echo -n ". "
    fi
      ((lp++)) #<--- Counts up the tempvar2
  done
  echo #<--prints new line for the containg loop
  ((hp++)) #<--- Counts up the tempvar
done 
}
######################





#Prompt for Start
echo "### WELCOME TO (INSERT NAME) ###"
echo "##       Move With WASD       ##"

#Allows promt to show for set time
sleep 2
#loops for the movement reading and q for quite
while [ $end -eq 0 ]; do
  drw

  #Silently reads the persons input... 
  #also causes visual glitch of letters appearing randomyl
  read -s -n1 move
  #determines add/sub player_x/y in the above read move
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

  #FOR TESTING
  echo $plyrx $plyry
  ##
done


