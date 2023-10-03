#!/bin/bash

# Script Name: webmin-ip-update.sh
#
# Description: Script which automatically changes the allowed IP on Webmin, depending on the dynamic IP assigned to the machine you are connecting from.
#
# Author: Unalignedcoder
# URL: https://github.com/unalignedcoder/webmin-ip-update/
# Copyright 2023 Unalignedcoder
# All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

#============== customize variables here

# Array of DNS servers to query
dnsServers=("resolver1.opendns.com" "8.8.8.8" "208.67.222.222" "77.88.8.1" "1.1.1.1")

# Define the file path for miniserv.conf
miniservConfPath="/etc/webmin/miniserv.conf"

# SSH into your remote VPS using the key stored in SSH agent
sshHost="<ip-number or server hostname>"
sshUser="<username with write privileges to miniserv.conf>"
sshPort="<port number>" # usually 22, custom number is recommended

# probably necessary. change this value depending on your experience
restartWebmin= true

#============== end customization


# Get the script's directory
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# File to store the last known IP
ipStore="$scriptDir/.last_known_ip.txt"

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
echo "IP address updated successfully." "New IP: $externalIP"

#restart Webmin
if $restartWebmin; then
  ssh -p "$sshPort" "$sshUser@$sshHost" "systemctl restart webmin"
  echo "Webmin restarted."
fi

# Send a desktop notification if `notify-send` is available (commonly in Ubuntu)
if type "notify-send" &> /dev/null; then
  notify-send "IP address updated successfully." "New IP: $externalIP"
  if $restartWebmin; then
    notify-send "Webmin restarted."
  fi
fi

# Update the IP store file with the current IP
echo "$externalIP" > "$ipStore"
