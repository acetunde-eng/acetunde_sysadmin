#!/bin/bash

file=${1}
IFS=$'\n'
((c=0))
for line in $(cat ${file})
do
#IFS=','
read -a data <<< ${line}
((c++))
hammer host update --build no --name ${data[0]}
hammer host update --build yes --name ${data[0]}


cat <<-CLOSE 
        ${data[0]} is successfully built up
       ========================================
CLOSE
done 
 
  echo "${c} kvms have been succesfully built up on foreman"
