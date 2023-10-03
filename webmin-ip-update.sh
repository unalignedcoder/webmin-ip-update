#!/bin/bash

#============== customize variables here

# Array of DNS servers to query
dnsServers=("resolver1.opendns.com" "8.8.8.8" "208.67.222.222" "77.88.8.1" "1.1.1.1")

# Get the script's directory
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Define the file path for miniserv.conf
miniservConfPath="/etc/webmin/miniserv.conf"

# SSH into your remote VPS using the key stored in SSH agent
sshHost="<ip-number or server hostname>"
sshUser="<username with write privileges to miniserv.conf>"
sshPort="<port number>" # usually 22, custom number is recommended

# File to store the last known IP
ipStore="$scriptDir/.last_known_ip.txt"

#============== end customization

# Query DNS servers to get the external IP address
function get_external_ip {
  for dnsServer in "${dnsServers[@]}"; do
    externalIP=$(dig +short myip.opendns.com @${dnsServer})
    if [[ -n $externalIP ]]; then
      echo "$externalIP"
      return
    fi
  done
  echo "Failed to retrieve external IP"
  exit 1
}

# Retrieve the external IP
externalIP=$(get_external_ip)

echo "Current IP: $externalIP"

# Check if the current IP is already in the miniserv.conf content
if ssh -p "$sshPort" "$sshUser@$sshHost" "grep -q 'allow=$externalIP' $miniservConfPath"; then
  echo "$externalIP is already allowed in Webmin. Nothing to do."
  exit
fi

# Edit miniserv.conf
ssh -p "$sshPort" "$sshUser@$sshHost" "sed -i 's/^allow=.*$/allow=$externalIP/' $miniservConfPath"

# Send a desktop notification if `notify-send` is available (commonly in Ubuntu)
if type "notify-send" &> /dev/null; then
  notify-send "IP address updated successfully." "New IP: $externalIP"
fi

# Update the IP store file with the current IP
echo "$externalIP" > "$ipStore"

echo "Notification: IP address updated successfully. New IP: $externalIP"
