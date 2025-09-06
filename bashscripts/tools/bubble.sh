#!/bin/bash


read -a input_arr

if [ -z input_arr ]; then
  exit 1
fi


num_elm=${#input_arr[@]}

  for (( d=0; d<25; d++ )); do
    for (( i=0; i<num_elm; i++ )); do
      if [[ ${input_arr[i]} -gt ${input_arr[i+1]} ]]; then

        temp_var=${input_arr[i+1]}
        input_arr[i+1]=${input_arr[i]}
        input_arr[i]=$temp_var

      fi
    done
  done

for (( i=1; i<num_elm; i++ )); do
   echo ${input_arr[i]}
done
