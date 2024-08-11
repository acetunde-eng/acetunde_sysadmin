#!/bin/bash

##############################################################################
################## PREPARE THE FILE FOR THE UPDATE ############################
##############################################################################

# Empty output file
truncate -s 0 /var/tmp/prunned_file.csv

#Prunning the Input file to remove the header row and === lines in between rows
sed '1d; /^=/d' /var/tmp/os_consistency_check_output1.csv > /var/tmp/os_consistency_check_output1_pruned.csv

# Input file and output file formats
input_file="/var/tmp/os_consistency_check_output1_pruned.csv"
output_file="/var/tmp/prunned_file.csv"

# Read the file line by line
if [ -f "$input_file" ]; then
   IFS=$'\n'
   while IFS=' ' read -r line; do
    # Use awk to insert a comma between the first and second fields
    output=$(echo "$line" | awk '{print $2","$3" "$5}')

    # Check if the third field is not equal to "CentOS"
        if [ "$(echo "$line" | awk '{print $3}')" != "CentOS" ]; then
            echo "$output" >> "$output_file"
        fi
   done < "$input_file"
else
   echo "File not found: $input_file"
fi

################################################################################
##################### THE OS UPDATE SECTION #######################################
################################################################################

# Function to update Foreman_OS
update_host_os() {
    local host_name="$1"
    local os_name="$2"

    # Get Host ID
    host_id=$(sudo hammer --csv host list --search "$host_name" | tail -n +2 | cut -d, -f1)

    if [ -z "$host_id" ]; then
        echo "Host $host_name not found. Skipping."
        return
    fi

    # Get OS ID
    os_id=$(sudo hammer --csv os list --search "$os_name" | tail -n +2 | cut -d, -f1)

    if [ -z "$os_id" ]; then
        echo "Operating System $os_name not found. Skipping."
        return
    fi

    # Update Host with new OS
    sudo hammer host update --id "$host_id" --operatingsystem-id "$os_id"

    echo "Host $host_name (ID: $host_id) is updated with OS $os_name (ID: $os_id)"
}

# Read the CSV file and process each line
while IFS=, read -r host_name os_name; do
    # Update host OS
    update_host_os "$host_name" "$os_name"
done < "$output_file"

