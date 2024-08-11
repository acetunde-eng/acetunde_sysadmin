#!/bin/bash

# Path to the CSV file
CSV_FILE="/var/tmp/hosts_to_delete.csv"

# Function to delete a node
delete_host() {
    local host_name="$1"

    # Delete the host
    sudo hammer host delete --name "$host_name"

    if [ $? -eq 0 ]; then
        echo "$host_name is deleted successfully."
    else
        echo "Failed to delete $host_name."
    fi
}

# Read the CSV file line by line
while IFS=, read -r host_name; do
    # Skip the header line
    if [[ "$host_name" == "Nodes Names" ]]; then
        continue
    fi
    
    # Execute the function to delete the node
    delete_host "$host_name"
done < "$CSV_FILE"

