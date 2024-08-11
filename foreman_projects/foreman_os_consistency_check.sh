#!/bin/bash

# Clear The Contents in allhosts file
truncate -s 0 /var/tmp/allhosts_in_foreman.csv

#Extract the Serial Numbers, The Machines' Names, OS and Version/Rellease from allhosts file
sudo hammer host list | sed -n '4, 10000p' | awk '{print NR, $3, $5, $6}' > /var/tmp/allhosts_in_foreman.csv
head -n -1 /var/tmp/allhosts_in_foreman.csv > /var/tmp/temp_allhosts_in_foreman.csv
mv /var/tmp/temp_allhosts_in_foreman.csv /var/tmp/allhosts_in_foreman.csv

#Generate the os installed on the machine
sudo hammer fact list --search "fact~os::release::f" | sed -n '4, 10000p' | awk '{print $0}' > /var/tmp/foreman_search_full.csv

# Clear The Contents in OS-check file
truncate -s 0 /var/tmp/os_consistency_check_output1.csv

# Write The Headings for the OS-check file
echo "     Machine_Names            OS   Foreman  On_Machine"  > /var/tmp/os_consistency_check_output1.csv

# Read from the allhosts file
file_path="/var/tmp/allhosts_in_foreman.csv"
if [ -f "$file_path" ]; then
   IFS=$'\n'
   for line in $(cat ${file_path}); do
     IFS=' '
     read -a data <<< ${line} 
     
     # To filter out a node with CenTOS Stream case.
     if [ "${data[1]}" == "kvm-s3562-1-ip156-01.cms" ]; then
         continue
     fi

     # Fetch The OS installed on The Machine 
     os_on_machine=$(cat /var/tmp/foreman_search_full.csv | grep ${data[1]} | awk '{printf $NF}' | paste -s)

     # Prune The OS installed on the machine and compare with its OS on Foreman; save only the inconsistency in the OS-check file
     first_three_digit=${os_on_machine:0:3}
     if [[ -n "$os_on_machine" && "${data[3]}" != "$first_three_digit" ]]; then
       echo -e "${data[0]}   ${data[1]}   ${data[2]}   ${data[3]}   $os_on_machine\n==============================================" >>  /var/tmp/os_consistency_check_output1.csv
     fi
   done
else
   echo "File not found: $file_path"
fi

# Display the OS-check file as stdout if fourth field is not equal to fifth field (To filter out RHEL 8.10 case) 
file_to_display="/var/tmp/os_consistency_check_output1.csv"

if [ -f "$file_to_display" ]; then
   awk '{ if ($4 != $5) print }' "$file_to_display"
else
   echo "File not found: $file_to_display"
fi

