#!/bin/bash

# Check if a filter parameter is provided
FILTER_STATUS="$1"

# Print Header
printf "%-30s %-40s %-10s %-15s %-50s\n" "Service Name" "Description" "Status" "User" "Path of Service"
echo "-----------------------------------------------------------------------------------------------------------------------------------------"

# Get a list of all services
systemctl list-units --type=service --all --no-pager --no-legend | awk '{print $1}' | while read service; do
    # Extract Service Information
    description=$(systemctl show "$service" --property=Description --value)
    status=$(systemctl is-active "$service")
    user=$(systemctl show "$service" --property=User --value)
    service_path=$(systemctl show "$service" --property=FragmentPath --value)

    # If a filter is provided, apply it
    if [[ -n "$FILTER_STATUS" && "$status" != "$FILTER_STATUS" ]]; then
        continue
    fi

    # Display Information in a table format
    printf "%-30s %-40s %-10s %-15s %-50s\n" \
        "$service" "$description" "$status" "$user" "$service_path"
done
