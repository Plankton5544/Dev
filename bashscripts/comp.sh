#!/bin/bash
# TODO:
# implement proper indexing for everything
# functionize all of it!

var=()
n1=()
n2=()
n3=()
n4=()
n5=()
n6=()
n7=()
n8=()
n9=()
nt=()
store=0


signature=$(dd if="$1" bs=1 count=45 2>/dev/null)

if [[ $signature != "3.141592653589793238462643383279502884197169x" ]] || [[ -z $1 ]]; then
  echo "FILE .NOT ACCEPTED"
  exit 1
fi
skip=46


interpret_byte() {
  local byte
  byte=$1

  if [[ $byte == ">" ]]; then
    store=1
  elif [[ $store == "1" ]]; then
    var+=("$byte")
    store=0
  fi

}

for ((i=0; i<20; i++)); do
  byte=$(dd if="$1" bs=1 count=1 skip=$skip 2>/dev/null)
  n1+=("$byte")
  skip=$((skip + 1))
done

skip=$((skip + 1))
for ((i=0; i<20; i++)); do
  byte1=$(dd if="$1" bs=1 count=1 skip=$skip 2>/dev/null)
  n2+=("$byte1")
  skip=$((skip + 1))
done

skip=$((skip + 1))
for ((i=0; i<20; i++)); do
  byte2=$(dd if="$1" bs=1 count=1 skip=$skip 2>/dev/null)
  n3+=("$byte2")
  skip=$((skip + 1))
done

skip=$((skip + 1))
for ((i=0; i<20; i++)); do
  byte3=$(dd if="$1" bs=1 count=1 skip=$skip 2>/dev/null)
  n4+=("$byte3")
  skip=$((skip + 1))
done

skip=$((skip + 1))
for ((i=0; i<20; i++)); do
  byte4=$(dd if="$1" bs=1 count=1 skip=$skip 2>/dev/null)
  n5+=("$byte4")
  skip=$((skip + 1))
done

skip=$((skip + 1))
for ((i=0; i<20; i++)); do
  byte5=$(dd if="$1" bs=1 count=1 skip=$skip 2>/dev/null)
  n6+=("$byte5")
  skip=$((skip + 1))
done

skip=$((skip + 1))
for ((i=0; i<20; i++)); do
  byte6=$(dd if="$1" bs=1 count=1 skip=$skip 2>/dev/null)
  n7+=("$byte6")
  skip=$((skip + 1))
done

skip=$((skip + 1))
for ((i=0; i<20; i++)); do
  byte7=$(dd if="$1" bs=1 count=1 skip=$skip 2>/dev/null)
  n8+=("$byte7")
  skip=$((skip + 1))
done

skip=$((skip + 1))
for ((i=0; i<20; i++)); do
  byte8=$(dd if="$1" bs=1 count=1 skip=$skip 2>/dev/null)
  n9+=("$byte8")
  skip=$((skip + 1))
done

skip=$((skip + 1))
for ((i=0; i<20; i++)); do
  byte9=$(dd if="$1" bs=1 count=1 skip=$skip 2>/dev/null)
  nt+=("$byte9")
  skip=$((skip + 1))
done









for item in "${n1[@]}"; do
  echo -n $item
  interpret_byte $item
done
echo " "
for item in "${n2[@]}"; do
  echo -n $item
  interpret_byte $item
done
echo " "
for item in "${n3[@]}"; do
  echo -n $item
  interpret_byte $item
done
echo " "
for item in "${n4[@]}"; do
  echo -n $item
  interpret_byte $item
done
echo " "
for item in "${n5[@]}"; do
  echo -n $item
  interpret_byte $item
done
echo " "
for item in "${n6[@]}"; do
  echo -n $item
  interpret_byte $item
done
echo " "
for item in "${n7[@]}"; do
  echo -n $item
  interpret_byte $item
done
echo " "
for item in "${n8[@]}"; do
  echo -n $item
  interpret_byte $item
done
echo " "
for item in "${n9[@]}"; do
  echo -n $item
  interpret_byte $item
done
echo " "
for item in "${nt[@]}"; do
  echo -n $item
  interpret_byte $item
done
echo " "


for item in "${var[@]}"; do
  echo $item
done

