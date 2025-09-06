#!/bin/bash
clear
if [ -f ~/money.txt ]; then
  money=$(cat ~/money.txt)
else
  echo "PLEASE CREATE 'money.txt' inside your ~ directory"
  echo "ENTER Defualt 100"
  exit 
fi
vr=2

echo "Total, $money"
echo "#BET#"
if [ "$money" > "0" ]; then
read -p "=>" bet
  if [ "$bet" = "vr" ]; then
    vr=1
    bet=1000
  fi
else
  echo "YOUR $money IS TOO SMALL"
  exit 
fi

outcome=$(( RANDOM % $vr + 1 ))

case $outcome in
  "2") total=$(( bet / 2 )) 
       cond=lose          
       money=$(( money - total ))      ;;
  "1") total=$(( bet * 2 )) 
       cond=win          
       money=$(( money + total ))      ;; 
  *) echo "ERROR in $outcome" & break  ;;
esac

echo "# OUTCOME #"
while [ "$lp" != "11" ]; do
  echo -n "."
  sleep 0.5
  ((lp++))
done
echo "
"
echo "You, $cond"
if [ $money -lt 0 ]; then
  echo "YOUR BANKRUPT!"
  echo $money > ~/money.txt
else
  echo "$money" > ~/money.txt
fi 
echo $money
read -t 5 -n 1 -s clear 
if [ "$clear" = "y" ]; then
  clear
elif [ "$clear" = "yes" ]; then
  clear
else
  exit
fi
