# Script Name: webmin-ip-update.ps1
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

# Path to plink executable
$plink = "C:\path\to\PLINK.EXE"

# Array of DNS servers to query
$dnsServers = @("resolver1.opendns.com", "8.8.8.8", "208.67.222.222", "77.88.8.1", "1.1.1.1")

# Define the file path for miniserv.conf
$miniservConfPath = "/etc/webmin/miniserv.conf"

# SSH into your remote VPS using the key stored in SSH agent (Pageant)
$sshHost = "<ip-number or server hostname>"
$sshUser = "<username with write privileges to miniserv.conf>"
$sshPort = "<port number>" # Usually 22, custom number is recommended

# File to store the last known IP
$ipStore = "$PSScriptRoot/.last_known_ip.txt"

# May be necessary. Change this value depending on your experience.
$restartWebmin = $true

#============== end customization


# Check if the BurntToast module is installed
if (-not (Get-Module -Name BurntToast -ListAvailable)) {
    Write-Host "Warning: BurntToast module is not installed. System notifications will not be displayed."
}

try {
    # Query DNS servers to get the external IP address
    function Get-ExternalIP {
        foreach ($dnsServer in $dnsServers) {
            $externalIP = (Resolve-DnsName -Name myip.opendns.com -Server $dnsServer).IPAddress
            if ($externalIP) {
                return $externalIP
            }
        }
        Write-Host "Failed to retrieve external IP"
    }

    # Call the Get-ExternalIP function to retrieve the external IP
    $externalIP = Get-ExternalIP

    # Export the $currentIP variable and log it to console
    $currentIP = $externalIP
    Write-Host "Current IP: $currentIP"

    # Read the old IP from the store file and Log it to console
    $oldIP = ""
    if (Test-Path -Path $ipStore) {
        $oldIP = Get-Content -Path $ipStore
		Write-Host "Last logged IP: $oldIP"
    }

	# Use Plink to check miniserv.conf content
    $miniservConfContent = Invoke-Expression -Command "$plink -ssh $sshUser@$sshHost -hostkey $hostKey -batch -P $sshPort cat $miniservConfPath"
	
    # Regular expression to match the 'allow=' line and its IP addresses
    $regex = 'allow=([^\n]*)'
    
    # Get the current 'allow=' line from miniserv.conf
    $currentAllowLine = ($miniservConfContent | Select-String -Pattern $regex).Matches.Groups[1].Value

    # Split the current 'allow=' line into an array of IP addresses/hostnames
    $allowIPs = $currentAllowLine.Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)

    # Check if the old IP exists in the array of IP addresses
    $oldIPIndex = $allowIPs.IndexOf($oldIP)

    # Check if the old IP exists and is different from the new IP
	if ($oldIPIndex -ne -1 -and $oldIP -ne $externalIP) {
		$allowIPs[$oldIPIndex] = $externalIP
	}
	elseif ($oldIP -eq $externalIP) {
		# If the old IP is the same as the new IP, exit the script
		Write-Host "$externalIP is already allowed in Webmin. Nothing to do."
		# Pause execution to keep the window open (debug feature)
        	# Read-Host "Press Enter to exit..."
		exit
	}
	else {
		# If the old IP doesn't exist, add the new IP to the array
		$allowIPs += $externalIP
	}


    # Reconstruct the 'allow=' line with the updated IP addresses
    $updatedAllowLine = "allow=" + ($allowIPs -join " ")

	# Use Plink to update miniserv.conf
	$sshCommand = "sed -i 's|^allow=.*|$updatedAllowLine|' $miniservConfPath"
	Invoke-Expression -Command "$plink -ssh $sshUser@$sshHost -hostkey $hostKey -batch -P $sshPort ""$sshCommand""" | Out-Null
	Write-Host "IP address updated successfully."

    
    # Restart Webmin if so specified
    if ($restartWebmin) {
        Invoke-Expression -Command "$plink -ssh $sshUser@$sshHost -hostkey $hostKey -batch -P $sshPort ""systemctl restart webmin"""
        Write-Host "Webmin restarted."
	    # Check if BurntToast is installed before attempting to display notification
	    if (Get-Module -Name BurntToast -ListAvailable) {
    	    New-BurntToastNotification -Text "Webmin restarted." -AppLogo "restart_services.png"
    	}
    }

    # Update the IP store file with the current IP
    $currentIP | Set-Content -Path $ipStore
	Write-Host "Most recent IP added to store file."

} catch {
	
    # Handle errors
    $errorMessage = $_.Exception.Message

	# Check if BurntToast is installed before attempting to display notifications
	if (Get-Module -Name BurntToast -ListAvailable) {
		# Notification when there's an error
		New-BurntToastNotification -Text "An error occurred: $errorMessage" -AppLogo "ip_block.png"
	}
		
	# Show console message anyhow
	Write-Host "Error: An error occurred: $errorMessage"
	
} 

# Pause execution to keep the window open (debug feature)
# Read-Host "Press Enter to exit..."
