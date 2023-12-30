#!/bin/bash

# Check if the script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Get username
read -p "Enter the username to grant full Polkit access: " username

# Get group
read -p "Enter the group to grant full Polkit access (or leave blank): " groupname

# Path to Polkit rule file
file="/etc/polkit-1/rules.d/99-full-access.rules"

# Confirm before proceeding
echo "This will create or overwrite Polkit rules in $file."
read -p "Are you sure you want to proceed? (y/n) " -n 1 -r
echo    # Move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

# Create or overwrite the Polkit rule file
echo "polkit.addRule(function(action, subject) {" > $file
if [ ! -z "$username" ]; then
    echo "    if (subject.user === \"$username\") {" >> $file
    echo "        return polkit.Result.YES;" >> $file
    echo "    }" >> $file
fi
if [ ! -z "$groupname" ]; then
    echo "    if (subject.isInGroup(\"$groupname\")) {" >> $file
    echo "        return polkit.Result.YES;" >> $file
    echo "    }" >> $file
fi
echo "});" >> $file

# Restart polkit
systemctl restart polkit

echo "Polkit rules updated successfully."
