#!/bin/bash

# Clear The Contents in allhosts file
truncate -s 0 allhosts_in_foreman.csv

#Extract the Serial Numbers, The Machines' Names, OS and Version/Rellease from allhosts file
sudo hammer host list | sed -n '4, 10000p' | awk '{print NR, $3, $5, $6}' > allhosts_in_foreman.csv
head -n -1 allhosts_in_foreman.csv > temp_allhosts_in_foreman.csv
mv temp_allhosts_in_foreman.csv allhosts_in_foreman.csv

sudo hammer fact list --search "fact~os::release::f" | sed -n '4, 10000p' | awk '{print $0}' > foreman_search_full.csv

# Clear The Contents in OS-check file
truncate -s 0 os_consistency_check_output1.csv

# Write The Headings for the OS-check file
echo "     Machine_Names            OS   Foreman  On_Machine" > os_consistency_check_output1.csv

# Read from the allhosts file
file_path="allhosts_in_foreman.csv"
if [ -f "$file_path" ]; then
   IFS=$'\n'
   for line in $(cat ${file_path}); do
   IFS=' '
   read -a data <<< ${line} 
# Generate The OS installed on The Machine 
   os_on_machine=$(cat foreman_search_full.csv | grep ${data[1]} | awk '{printf $NF}' | paste -s)

# Compare The OS in Foreman With The OS installed on The Machine and save only the inconsistency in the OS-check file
   first_three_digit=${os_on_machine:0:3}
   if [[ -n "$os_on_machine" && "${data[3]}" != "$first_three_digit" ]]; then
      echo -e "${data[0]}   ${data[1]}   ${data[2]}   ${data[3]}       $os_on_machine\n=================================================" >>  os_consistency_check_output1.csv
   fi
   done
else
   echo "File not found: $file_path"
fi
# Display the OS-check file as stdout
#file_to_display="/var/tmp/os_consistency_check_output1.csv"
#cat "$file_to_display"
