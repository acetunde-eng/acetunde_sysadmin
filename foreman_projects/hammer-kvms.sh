#!/bin/bash

file=${1}
IFS=$'\n'
((c=0))
((sum=0))
for line in $(cat ${file})
do
IFS=','
read -a data <<< ${line}
((c++))
hammer host create --architecture x86_64 --environment  puppet7 --domain cms --subnet cms --hostgroup-title "el9/alma/p5/spare" --owner-id 2 --managed yes --medium "CERN ALMA9 Generic" --build yes --operatingsystem "ALMA 9.1" --partition-table CMS_LVM_noswap --model "oVirt Node" --name  ${data[0]} --interface primary=true,mac=${data[2]},provision=true --ip ${data[1]} --location P5 --organization "Default Organization"

cat <<-CLOSE 
        ${data[0]} is successfully configured
       ========================================
CLOSE
done 
 
  echo "${c} kvms have been succesfully configured on foreman"
