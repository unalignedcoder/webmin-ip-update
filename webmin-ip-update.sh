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

<<<<<<< HEAD
#============== version

scriptVersion="1.0.2"

=======
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
#============== Paths

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

<<<<<<< HEAD
#============== Separate SSH Config file

# Load configuration from an external file for privacy reasons
configFile="$scriptDir/SSHconfig.env"

if [ -f "$configFile" ]; then
    source "$configFile"
else
    echo "Error: Configuration file not found at $configFile"
    exit 1
fi

# SSH variables to be used to Log in to the server
sshHost="$SSH_HOST"
sshUser="$SSH_USER"
sshPort="$SSH_PORT"
hostKey="$HOST_KEY"

#============== Customize variables HERE

# Array of DNS servers to query
# dnsServers=("resolver1.opendns.com" "8.8.8.8" "208.67.222.222" "77.88.8.1" "1.1.1.1")
=======
#============== Customize variables HERE

# Array of IP services to query 
# thanks to https://www.scriptinglibrary.com/languages/powershell/how-to-get-your-external-ip-with-powershell-core-using-a-restapi/
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
ipServices=("https://icanhazip.com", "https://api.ipify.org", "https://ipinfo.io/json | select-object -ExpandProperty ip", "https://jsyk.it/ip")

# Define the file path for miniserv.conf
miniservConfPath="/etc/webmin/miniserv.conf"

<<<<<<< HEAD
=======
# SSH into your remote VPS using the key stored in Pageant
sshHost="<ip-number or server hostname>"
sshUser="<username with write privileges to miniserv.conf>"
sshPort="<port number>" # Usually 22, custom number is recommended
hostKey="<Public Host Key Fingerprint in the key-type:host-key format>" # Probably necessary only the first time the script is run

>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
# File to store the last known IP
ipStore="$scriptDir/.last_known_ip.txt"

# Restart Webmin? May not work if set to false
restartWebmin="true"

# Should multiple IPs be allowed?
multipleIPs="false"

# Create log file? For debugging purposes
logFile="true"

#should the log file be printed in reverse order?
logReverse="true"

# Define a log file path
logFilePath="$scriptDir/script.log"


#============== Functions

<<<<<<< HEAD
# Function to log messages in reverse order
function Write-Log {
    local Message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local logEntry="$timestamp - $Message"

    if [ "$logFile" = true ]; then
        if [ "$logReverse" = true ]; then
            # Prepend the log entry to the log file
            { echo "$logEntry"; cat "$logFilePath"; } > "$logFilePath.tmp"
            mv "$logFilePath.tmp" "$logFilePath"
        else
            echo "$logEntry" >> "$logFilePath"
        fi
=======
# Function to log messages to a file
function Log-Message {
    local Message="$1"
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local logEntry="$timestamp - $Message"
    
    # Do only if Logging is enabled
    if [ "$logFile" = true ]; then
		# should the log be reversed?
		if [ "$logReverse" = true ]; then		
			echo "$logEntry" | sed "1i$logEntry" > "$logFilePath.tmp"
			mv "$logFilePath.tmp" "$logFilePath"
		else
			echo "$logEntry" >> "$logFilePath"
		fi
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
    fi
}

# Query IP services to get the external IP address
function GetExternalIP() {
    for ipService in "${ipServices[@]}"; do
		#| tr -d '[:space:]' adds trimming to the output
        externalIP=$(curl -s --max-time 10 "$ipService" | tr -d '[:space:]')
        if [ -n "$externalIP" ]; then
            echo "Your IP appears to be $externalIP"
            return 0
        else
            errorMessage="Failed to retrieve external IP from $ipService. Error: $?"
            LogMessage "$errorMessage"
        fi
    done

    # Failed to retrieve external IP from any IP service
    LogMessage "Failed to retrieve external IP from any IP service. Exiting."
    exit 1
}

<<<<<<< HEAD
=======

>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
# Display desktop notifications using available tools
function Show-Notification {
    local Title="Webmin Allowed IP update"
    local Text="$1"
    local Icon="$2"

    if command -v notify-send &>/dev/null; then
        notify-send "$Title" "$Text" -i "$Icon"
    elif command -v kdialog &>/dev/null; then
        kdialog --passivepopup "$Text" 5 --icon "$Icon" --title "$Title"
    elif command -v zenity &>/dev/null; then
        zenity --info --title "$Title" --text="$Text" --window-icon="$Icon"
    else
<<<<<<< HEAD
        Write-Log "No notification tool (notify-send, kdialog, or zenity) is installed. Cannot display system notifications."
=======
        Log-Message "No notification tool (notify-send, kdialog, or zenity) is installed. Cannot display system notifications."
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
    fi
}

# Define a function to handle errors
function Handle-Error {
    local errorMessage="$1"
	
<<<<<<< HEAD
    Write-Log "Error: An error occurred: $errorMessage"
=======
    Log-Message "Error: An error occurred: $errorMessage"
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
    Show-Notification "Error: An error occurred: $errorMessage" "error.png"
    exit 1
}

<<<<<<< HEAD
# Function to check if KeePassXC is running and launch it if not
function Open-KeePassXC {
    if pgrep -x "keepassxc" > /dev/null; then
        Write-Log "KeePassXC is already running."
    else
        Write-Log "KeePassXC is not running. Attempting to launch..."
        if command -v keepassxc &>/dev/null; then
            keepassxc &
            sleep 2
            Write-Log "KeePassXC launched. Please load your SSH keys."
        else
            Write-Log "KeePassXC is not installed. Cannot launch it."
        fi
    fi
}

# Function to check if SSH agent is running and keys are loaded
function Test-SSHKeys {
    if pgrep -x "ssh-agent" > /dev/null; then
        Write-Log "SSH agent is running. Checking for loaded keys..."
        if ssh-add -l &>/dev/null; then
            Write-Log "SSH keys are loaded."
        else
            Write-Log "No SSH keys loaded. Please load your keys."
            Open-KeePassXC
            read -p "Press Enter to continue once keys are loaded..."
            if ! ssh-add -l &>/dev/null; then
                Write-Log "SSH keys still not loaded. Exiting."
                exit 1
            fi
        fi
    else
        Write-Log "No SSH agent running. Please start an SSH agent and load your keys."
        exit 1
    fi
}

# Function to handle SSH authentication errors
function Handle-SSHError {
    Write-Log "SSH authentication failed. Please check your SSH keys."
    Open-KeePassXC
    read -p "Press Enter to retry SSH authentication..."
    if ! ssh-add -l &>/dev/null; then
        Write-Log "SSH keys still not loaded correctly. Exiting."
        exit 1
    fi
}

# Retry mechanism for SSH key loading
function Retry-SSHKeys {
    while true; do
        Test-SSHKeys
        if ssh-add -l &>/dev/null; then
            Write-Log "SSH keys loaded successfully."
            break
        else
            read -p "SSH keys not loaded. Retry? (y/n): " retry
            if [[ "$retry" != "y" ]]; then
                Write-Log "Exiting due to missing SSH keys."
                exit 1
            fi
        fi
    done
}

#============== Execution

# Start log session
Write-Log "===== New Log Session ====="
Write-Log "Script: Bash Shell"

# Check SSH keys before proceeding
Retry-SSHKeys

# Call the Get-ExternalIP function to retrieve the external IP
externalIP=$(GetExternalIP)

# Log the current IP
Write-Log "Current IP: $externalIP"
=======
#============== Execution


# Start log session
Log-Message "===== New Log Session ====="
Log-Message "Script: Bash Shell"

# Call the Get-ExternalIP function to retrieve the external IP
externalIP=$(Get-ExternalIP)

# Log the current IP
Log-Message "Current IP: $externalIP"
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc

# Read the old IP from the store file and log it
oldIP=""
if [ -f "$ipStore" ]; then
<<<<<<< HEAD
    oldIP=$(cat "$ipStore")
    Write-Log "Last logged IP: $oldIP"
=======
	oldIP=$(cat "$ipStore")
	Log-Message "Last logged IP: $oldIP"
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
fi

# Use sed to check miniserv.conf content
currentAllowLine=$(ssh -p "$sshPort" "$sshUser@$sshHost" "grep 'allow=' $miniservConfPath")

# Regular expression to match the 'allow=' line and its IP addresses
regex='allow=([^\n]*)'

# Get the current 'allow=' line from miniserv.conf
if [[ "$currentAllowLine" =~ $regex ]]; then
<<<<<<< HEAD
    currentAllowLine="${BASH_REMATCH[1]}"
=======
	currentAllowLine="${BASH_REMATCH[1]}"
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
fi

# Split the current 'allow=' line into an array of IP addresses/hostnames
IFS=' ' read -ra allowIPs <<< "$currentAllowLine"

# Check if the old IP exists in the array of IP addresses
oldIPIndex=-1
for i in "${!allowIPs[@]}"; do
<<<<<<< HEAD
    if [[ "${allowIPs[i]}" == "$oldIP" ]]; then
        oldIPIndex=$i
        break
    fi
=======
	if [[ "${allowIPs[i]}" == "$oldIP" ]]; then
		oldIPIndex=$i
		break
	fi
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
done

# Check if the old IP exists and is different from the new IP
if [ "$oldIPIndex" -ne -1 ] && [ "$oldIP" != "$externalIP" ]; then
<<<<<<< HEAD
    allowIPs["$oldIPIndex"]=$externalIP
elif [ "$oldIP" == "$externalIP" ]; then
    # If the old IP is the same as the new IP, exit the script
    Write-Log "$externalIP is already allowed in Webmin. Nothing to do."
    # Pause execution to keep the window open (debug feature)
    # read -p "Press Enter to exit..."
    exit
else
    # If the old IP doesn't exist, add the new IP to the array
    allowIPs+=("$externalIP")
=======
	allowIPs["$oldIPIndex"]=$externalIP
elif [ "$oldIP" == "$externalIP" ]; then
	# If the old IP is the same as the new IP, exit the script
	Log-Message "$externalIP is already allowed in Webmin. Nothing to do."
	# Pause execution to keep the window open (debug feature)
	# read -p "Press Enter to exit..."
	exit
else
	# If the old IP doesn't exist, add the new IP to the array
	allowIPs+=("$externalIP")
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
fi

# Check if preserving multiple allowed IPs is necessary
if [ "$multipleIPs" = true ]; then
    # Reconstruct the 'allow=' line with the updated IP addresses
    updatedAllowLine="allow=$(IFS=" "; echo "${allowIPs[*]}")"
else
    # If multiple IPs are not needed, only include the most recent one
    updatedAllowLine="allow=$externalIP"
fi

# Use sed to update miniserv.conf (customize this part for your setup)
ssh -p "$sshPort" "$sshUser@$sshHost" "sed -i 's|^allow=.*|$updatedAllowLine|' $miniservConfPath"

# Show notification
<<<<<<< HEAD
Write-Log "IP address updated successfully. New IP: $externalIP"
=======
Log-Message "IP address updated successfully.New IP: $externalIP"
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
Show-Notification "IP address updated successfully.\nNew IP: $externalIP" "ip.png"

# Restart Webmin if specified
if $restartWebmin; then
<<<<<<< HEAD
    ssh -p "$sshPort" "$sshUser@$sshHost" "systemctl restart webmin"
    
    # Show notification
    Write-Log "Webmin restarted."
    Show-Notification "Webmin restarted." "webmin.png"
=======
	ssh -p "$sshPort" "$sshUser@$sshHost" "systemctl restart webmin"
	
	# Show notification
	Log-Message "Webmin restarted."
	Show-Notification "Webmin restarted." "webmin.png"
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
fi

# Update the IP store file with the current IP
echo "$externalIP" > "$ipStore"
<<<<<<< HEAD
Write-Log "Most recent IP added to store file."
=======
Log-Message "Most recent IP added to store file."
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc

# Pause execution to keep the window open (debug feature)
# read -p "Press Enter to exit..."

<<<<<<< HEAD
# Exit normally if no errors occurred
exit 0
=======
# exit normally if no errors occurred
exit 0
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
