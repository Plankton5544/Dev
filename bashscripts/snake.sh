#!/bin/bash


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
####################



#Title Echo And Read Difficulty
echo "#### WELCOME TO SNAKE #####"
echo "###########################"
echo "# Enter Difficulty (1-10) #"
read -p "=> " diff

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
  snake=" "
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
drw() {
  clear
  hp=1
  while [ "$hp" -le "$height" ]; do
    lp=1
      while [ "$lp" -le "$width" ]; do
         if [ "$lp" -eq "$plyrx" ] && [ "$hp" -eq "$plyry" ]; then
            echo -n "$snake "
         elif [ $lp -eq $fdx ] && [ $hp -eq $fdy ]; then
            echo -n "* "
            #Horrible If Statements From Future Brute Force... UGH...
         elif [ "$lp" = "$oldx" ] && [ "$hp" = "$oldy" ]; then
           echo -n "0 "
          elif [ "$lp" = "$ooldx" ] && [ "$hp" = "$ooldy" ]; then
            echo -n "O "
           elif [ "$lp" = "$oooldx" ] && [ "$hp" = "$oooldy" ]; then
              echo -n "0 "
            elif [ "$lp" = "$Oldx" ] && [ "$hp" = "$Oldy" ]; then
                echo -n "O "
              elif [ "$lp" = "$OLdx" ] && [ "$hp" = "$OLdy" ]; then
                 echo -n "0 "
                elif [ "$lp" = "$OLDx" ] && [ "$hp" = "$OLDy" ]; then
                  echo -n "0 "
                  elif [ "$lp" = "$OLDX" ] && [ "$hp" = "$OLDY" ]; then
                     echo -n "0 "
                   elif [ "$lp" = "$oLDX" ] && [ "$hp" = "$oLDY" ]; then
                     echo -n "0 "
                    elif [ "$lp" = "$olDX" ] && [ "$hp" = "$olDY" ]; then
                      echo -n "0 "
                     elif [ "$lp" = "$oldX" ] && [ "$hp" = "$oldY" ]; then
                       echo -n "0 "
         else 
            echo -n "$background "
         fi

         ((lp++))
       done
       echo 
       ((hp++))
    done
if [ $plyrx -eq $fdx ] && [ $plyry -eq $fdy ]; then
  fd
  ((tail++))
fi
if [ "$plyrx" = "$ooldx" ] && [ "$plyry" = "$ooldy" ] || [ "$plyrx" = "$oooldx" ] && [ "$plyry" = "$oooldy" ] || [ "$plyrx" = "$Oldx" ] && [ "$plyry" = "$Oldy" ] || [ "$plyrx" = "$OLdx" ] && [ "$plyry" = "$OLdy" ] || [ "$plyrx" = "$OLDx" ] && [ "$plyry" = "$OLDy" ] || [ "$plyrx" = "$OLDX" ] && [ "$plyry" = "$OLDY" ] || [ "$plyrx" = "$oLDX" ] && [ "$plyry" = "$oLDY" ] || [ "$plyrx" = "$olDX" ] && [ "$plyry" = "$olDY" ] || [ "$plyrx" = "$oldX" ] && [ "$plyry" = "$oldY" ]; then 
#Ridiculous Brute Force Checks From Previous...
end=1
fi
}
######################

dirx=1
diry=0

####################
#Main Loop With End#
####################
while [ $end -eq 0 ]; do 
  #Brute Force For Tail Its Ugly And Buggy...
  if [[ "$tail" -gt 100 ]]; then
    inter=0.00000000067
  fi
if [[ "$tail" -gt 50 ]]; then
  inter=0.00000069
fi
  if [[ "$tail" -gt 40 ]]; then
  fdy=$(( RANDOM % $height + 1 ))
  fi
    if [[ "$tail" -gt 30 ]]; then
          inter=0.0001
        fi
      if [[ "$tail" -gt 26 ]]; then
        inter=0.0125
      fi
        if [[ "$tail" -gt 24 ]]; then
           inter=0.025
        fi

          if [[ "$tail" -gt 22 ]]; then
            inter=0.05
          fi
                if [[ "$tail" -gt 20 ]]; then
                oldY=$olDY
                oldX=$olDX
                fi
              if [[ "$tail" -gt 18 ]]; then
              olDY=$oLDY
              olDX=$oLDX
              fi
            if [[ "$tail" -gt 16 ]]; then
            oLDY=$OLDY
            oLDX=$OLDX
            fi
          if [[ "$tail" -gt 14 ]]; then
          OLDY=$OLDy
          OLDX=$OLDx
          fi
         if [[ "$tail" -gt 12 ]]; then
         OLDy=$OLdy
         OLDx=$OLdx
         fi
        if [[ "$tail" -gt 10 ]]; then
        OLdy=$Oldy
        OLdx=$Oldx
        fi
        if [[ "$tail" -gt 8 ]]; then
      Oldy=$oooldy
      Oldx=$oooldx
        fi
      if [[ "$tail" -gt 6 ]]; then
     oooldy=$ooldy
     oooldx=$ooldx
      fi
     if [[ "$tail" -gt 4 ]]; then
   ooldy=$oldy
   ooldx=$oldx
     fi
if [[ "$tail" -gt 2 ]]; then
  oldy=$plyry
  oldx=$plyrx
fi

  read -t $inter -n 1 -s move

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
