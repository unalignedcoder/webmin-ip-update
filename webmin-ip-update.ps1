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

#path to plink executable
$plink = "C:\path\to\PLINK.EXE"

# Array of DNS servers to query
$dnsServers = @("resolver1.opendns.com", "8.8.8.8", "208.67.222.222", "77.88.8.1", "1.1.1.1")

# Define the file path for miniserv.conf
$miniservConfPath = "/etc/webmin/miniserv.conf"

# SSH into your remote VPS using the key stored in Pageant
$sshHost = "<ip-number or server hostname>"
$sshUser = "<username with write privileges to miniserv.conf>"
$sshPort = "<port number>" #usually 22, custom number is recommended
$hostKey = "<host key fingerprint>" #in the `key-type:host-key` format

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
	$env:currentIP = $externalIP
	Write-Host "Current IP: $env:currentIP"
	
	#Use Plink to check miniserv.conf content
	$miniservConfContent = Invoke-Expression -Command "$plink -ssh $sshUser@$sshHost -hostkey $hostKey -batch -P $sshPort cat $miniservConfPath"
	
	# Check if the current IP is already in the miniserv.conf content
	$ipAlreadyExists = $miniservConfContent -match "allow=$env:currentIP"
	
	# If the IP already exists, exit without making changes
	if ($ipAlreadyExists) {
		Write-Host "$env:currentIP is already allowed in Webmin. Nothing to do."
		# Pause execution to keep the window open (debug feature)
		# Read-Host "Press Enter to exit..."
		exit
	}
			
	#SSH command
	$sshEdit = "sed -i 's/^allow=.*$/allow=$env:currentIP/'"
	
    # Use Plink to edit miniserv.conf ("&& systemctl restart webmin" probably not needed)
    Start-Process -FilePath "$plink" -ArgumentList "-ssh $sshUser@$sshHost -hostkey $hostKey -batch -P $sshPort ""$sshEdit"" $miniservConfPath" -NoNewWindow -Wait

    # Check if BurntToast is installed before attempting to display notification
    if (Get-Module -Name BurntToast -ListAvailable) {
		New-BurntToastNotification -Text "IP address updated successfully.`nNew IP: $externalIP" -AppLogo "ip.png"
		} 
	#show console message anyhow
	Write-Host "Notification: IP address updated successfully. New IP: $externalIP"
	
} catch {
	
    # Handle errors
    $errorMessage = $_.Exception.Message

	# Check if BurntToast is installed before attempting to display notifications
		if (Get-Module -Name BurntToast -ListAvailable) {
			# Notification when there's an error
			New-BurntToastNotification -Text "An error occurred: $errorMessage" -AppLogo "ip_block.png"
		}
		
	#show console message anyhow
	Write-Host "Error: An error occurred: $errorMessage"
	
} 

# Pause execution to keep the window open (debug feature)
# Read-Host "Press Enter to exit..."
