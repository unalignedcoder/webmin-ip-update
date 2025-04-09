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

<<<<<<< HEAD
#============== version

$scriptVersion="1.0.2"

#============== Separate SSH Config file

# Load configuration from an external file for privacy reasons
$configFile = Join-Path -Path $PSScriptRoot -ChildPath "SSHconfig.env"

if (Test-Path -Path $configFile) {
    Get-Content -Path $configFile | ForEach-Object {
        if ($_ -match "^(.*?)=(.*)$") {
            Set-Variable -Name $matches[1] -Value $matches[2]
        }
    }
} else {
    Write-Host "Error: Configuration file not found at $configFile"
    exit 1
}

# SSH variables to be used to Log in to the server
$sshHost = $SSH_HOST
$sshUser = $SSH_USER
$sshPort = $SSH_PORT
$hostKey = $HOST_KEY

#============== customize variables here

# Path to plink executable
$plink = "B:\programs\PuTTYPortable\App\putty\PLINK.EXE"
=======
#============== Customize the following variables to your needs

# Path to plink executable
$plink = "PLINK.EXE"
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc

# Array of IP services to query 
# thanks to https://www.scriptinglibrary.com/languages/powershell/how-to-get-your-external-ip-with-powershell-core-using-a-restapi/
$ipServices = @("https://icanhazip.com", "https://api.ipify.org", "https://ipinfo.io/json | select-object -ExpandProperty ip", "https://jsyk.it/ip")

# Define the file path for miniserv.conf
$miniservConfPath = "/etc/webmin/miniserv.conf"

<<<<<<< HEAD
=======
# SSH variables
$sshHost = "<ip-number or server hostname>"
$sshUser = "<username with write privileges to miniserv.conf>"
$sshPort = "<port number>" # Usually 22, custom number is recommended
$hostKey = "<Public Host Key Fingerprint in the key-type:host-key format>" # Probably necessary only the first time the script is ran

>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
# File to store the last known IP
$ipStore = "$PSScriptRoot/.last_known_ip.txt"

# Restart Webmin? May not work if set to false
$restartWebmin = $true

# Should multiple IPs be allowed?
$multipleIPs = $false

<<<<<<< HEAD
# Prompt to Open KeePassXC?
$openKeePassXC = $true

# Use the specific path you mentioned works in cmd
$keepassPath = "B:\programs\KeePassXC\KeePassXC.exe"

# Add reference to System.Windows.Forms for SendKeys
Add-Type -AssemblyName System.Windows.Forms

=======
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
# Create log file? For debugging purposes
$logFile = $true

#should the log file be printed in reverse order?
$logReverse = $true

# Define a log file path
$logFilePath = "$PSScriptRoot\script.log"

#============== Functions

# Function to log messages to a file
<<<<<<< HEAD
function Write-Log  {
=======
function Log-Message {
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
	param (
		[string]$Message
	)

	$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
	$logEntry = "$timestamp - $Message"
	
	# do only if Logging is enabled
	if ($logFile) {
		#check if printing in reverse or not
		if ($logReverse) {
			
			# Read the existing content of the log file
			$existingContent = Get-Content -Path $logFilePath -Raw

			# Prepend the new log entry to the existing content
			$updatedContent = "$logEntry`n$existingContent"

			# Write the updated content back to the log file
			$updatedContent | Set-Content -Path $logFilePath -Encoding UTF8
			
		} else {
			
			$logEntry | Out-File -Append -FilePath $logFilePath -Encoding UTF8
		}

	}
}

# Query IP services to get the external IP address
function Get-ExternalIP {
    foreach ($ipService in $ipServices) {
        try {
            $externalIP = (Invoke-WebRequest -Uri $ipService -ErrorAction Stop).Content.Trim()
            if ($externalIP) {
<<<<<<< HEAD
                Write-Log -Message "Your IP appears to be $externalIP"
=======
                Log-Message -Message "Your IP appears to be $externalIP"
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
                return $externalIP
            }
        } catch {
            $errorMessage = "Failed to retrieve external IP from $ipService. Error: $_"
<<<<<<< HEAD
            Write-Log -Message $errorMessage
=======
            Log-Message -Message $errorMessage
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
        }
    }

    # Write-Host "Failed to retrieve external IP"
<<<<<<< HEAD
    Write-Log -Message "Failed to retrieve external IP from any IP service. Exiting."
    throw "Failed to retrieve external IP"      
}

=======
    Log-Message -Message "Failed to retrieve external IP from any IP service. Exiting."
    throw "Failed to retrieve external IP"      
}


>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
# unneeded for IP services, required for DNS requests
# Check if the IP contains both v4 and v6 parts, extract IPv4
<#if($externalIP -match '\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}(?:\s*:\S*)?') {
	$ipParts = $externalIP.Split(':')
	$ipv4Part = $ipParts[-1].TrimStart('.')
	$externalIP = $ipv4Part
<<<<<<< HEAD
} #>					
=======
} #>
					
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
			
# Display BurntToast Notifications
function Show-BurntToastNotification {
	param(
		[string]$Text,
		[string]$AppLogo
	)
	
	# Install the BurntToast module if not already installed
<<<<<<< HEAD
	if (-not (Get-Module -Name BurntToast -ListAvailable )) {
        
=======
	if (-not (Get-Module -Name BurntToast -ListAvailable )) {			
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
		Install-Module -Name BurntToast -Scope CurrentUser
	}
	
	# for when the above is commented out, we log a message.
	if (Get-Module -Name BurntToast -ListAvailable) {
<<<<<<< HEAD

		New-BurntToastNotification -Text $Text -AppLogo $AppLogo

	} else {

		Write-Log -Message "BurntToast module is not installed. Cannot display system notifications."
        Write-Host "BurntToast module is not installed. Cannot display system notifications."
	}
}

# Try to bring KeePassXC to foreground or launch it
function Open-KeePassXC {

    try {
        # Check if KeePassXC is already running
        $process = Get-Process -Name "KeePassXC" -ErrorAction SilentlyContinue
        
        if ($process) {
            # KeePassXC is running, try to bring it to foreground
            Write-Log -Message "KeePassXC is running, bringing to foreground..."
            Write-Host "KeePassXC is running, bringing to foreground..."
                       
            # Start the process with a minimized window, then maximize it to force focus
            Start-Process $keepassPath -WindowStyle Minimized
            Start-Sleep -Milliseconds 500
            
            # Get the process again and set focus
            $process = Get-Process -Name "KeePassXC" -ErrorAction SilentlyContinue
            if ($process) {
                $null = [System.Runtime.InteropServices.Marshal]::GetActiveObject("WScript.Shell")
                $null = [System.Runtime.InteropServices.Marshal]::GetActiveObject("WScript.Shell").AppActivate($process.MainWindowTitle)
            }
            
            Write-Log -Message "KeePassXC brought to foreground."
            return $true

        } else {

            # KeePassXC is not running, launch it
            Write-Log -Message "KeePassXC not running, attempting to launch..."
            Write-Host "KeePassXC not running, attempting to launch..."
            
            # Use direct path instead of just the name
            Start-Process "$keepassPath" -ErrorAction Stop
            
            # Wait a moment for the application to start
            Start-Sleep -Seconds 2
            
            Write-Log -Message "KeePassXC launched."
            Write-Host "KeePassXC launched. Please load your SSH keys."
            return $true
        }

    } catch {

        Write-Log -Message "Failed to launch KeePassXC: $_"
        Write-Host "Failed to launch KeePassXC: $_"
        Write-Host "Please open KeePassXC manually to load your SSH keys."
        return $false
    }
}

# Test if SSH connection works with current keys
function Test-SSHConnection {

    try {

        $testOutput = Invoke-Expression -Command "$plink -ssh $sshUser@$sshHost -hostkey $hostKey -batch -P $sshPort echo 'test'" -ErrorAction Stop
        if ($testOutput -eq "test") {

            Write-Log -Message "SSH connection test successful."
            Write-Host "SSH connection test successful."
            return $true
        }

    } catch {

        Write-Log -Message "SSH connection test failed: $_"
        Write-Host "SSH connection test failed. Please check your SSH keys."
    }
    return $false
}

#==============  SSH Agents checks (it's either Pageant or OpenSSH)

# Check if Pageant has SSH keys loaded and handle the situation
function Test-SSHKeys {

    $processPageant = Get-Process -Name "Pageant" -ErrorAction SilentlyContinue
    $keysLoaded = $false

    if ($null -ne $processPageant) {

        # Pageant is running, check if keys are properly loaded
        Write-Log -Message "Pageant is running. Testing SSH connection..."
        Write-Host "Pageant is running. Testing SSH connection..."

        $keysLoaded = Test-SSHConnection
        
        if (-not $keysLoaded) {

            $errorMessage = "Pageant is running but your SSH keys are not loaded correctly."
            Write-Log -Message "Warning: $errorMessage"
            Show-BurntToastNotification -Text "Warning: $errorMessage" -AppLogo "error.png"
            Write-Host "Warning: $errorMessage"
            
            # Try to open KeePassXC
            Open-KeePassXC
            
            # Wait for user to confirm keys are loaded
            Write-Host "Please ensure your SSH keys are loaded in KeePassXC/Pageant."
            Read-Host "Press Enter to continue once keys are loaded"
            
            # Recheck keys after user action
            $keysLoaded = Test-SSHConnection

            if ($keysLoaded) {

                Write-Log -Message "SSH keys are now properly loaded."
                Write-Host "SSH keys are now properly loaded."

            } else {

                $errorMessage = "SSH keys still not loaded or authentication failed."
                Write-Log -Message "Error: $errorMessage"
                Show-BurntToastNotification -Text "Error: $errorMessage" -AppLogo "error.png"
                Write-Host "Would you like to try again? (Y/N)"

                $retry = Read-Host

                if ($retry -eq "Y" -or $retry -eq "y") {

                    return Test-SSHKeys # Recursively check again

                } else {

                    exit 1
                }
            }
        }
    } elseif ($null -ne $env:SSH_AUTH_SOCK) {

        # OpenSSH agent is running
        Write-Log -Message "OpenSSH agent detected. Checking for loaded keys..."
        Write-Host "OpenSSH agent detected. Checking for loaded keys..."
        
        # Check if SSH keys are loaded in OpenSSH agent
        $sshKeysLoaded = $null

        try {

            $sshKeysLoaded = ssh-add -l 2>$null

        } catch {

            # Error occurred, likely due to no keys loaded
            $sshKeysLoaded = $null
        }

        if ($null -eq $sshKeysLoaded) {

            # No keys loaded, provide a warning
            $errorMessage = "OpenSSH agent is running, but no SSH keys are loaded."
            Write-Log -Message "Warning: $errorMessage"
            Show-BurntToastNotification -Text "Warning: $errorMessage" -AppLogo "error.png"
            Write-Host "Warning: $errorMessage"
            
            # Wait for user to load keys
            Write-Host "Please load your SSH keys."
            Read-Host "Press Enter to continue once keys are loaded"
            
            # Recheck
            try {

                $sshKeysLoaded = ssh-add -l 2>$null
                if ($null -eq $sshKeysLoaded) {

                    $errorMessage = "SSH keys still not loaded in OpenSSH agent."
                    Write-Log -Message "Error: $errorMessage"
                    Write-Host "Error: $errorMessage"
                    throw "No keys loaded"
                }

                Write-Log -Message "SSH keys are now loaded in OpenSSH agent."
                Write-Host "SSH keys are now loaded in OpenSSH agent."
                $keysLoaded = $true

            } catch {

                $errorMessage = "SSH keys still not loaded. Exiting."
                Write-Log -Message "Error: $errorMessage"
                Show-BurntToastNotification -Text "Error: $errorMessage" -AppLogo "error.png"
                Write-Host "Error: $errorMessage"
                exit 1
            }
        } else {

            Write-Log -Message "SSH keys are loaded in OpenSSH agent."
            Write-Host "SSH keys are loaded in OpenSSH agent."
            $keysLoaded = $true
        }

    } else {
        # Neither Pageant nor OpenSSH agent is running
        $errorMessage = "Could not find any SSH Agent running. Please start an SSH agent and load your SSH keys before running this script."
        Write-Log -Message "Warning: $errorMessage"
        Show-BurntToastNotification -Text "Warning: $errorMessage" -AppLogo "error.png"
        Write-Host "Warning: $errorMessage"
        exit 1
    }
    
    return $keysLoaded
}

#============== Execution

try {
	#Start log session
	Write-Log -Message "===== New Log Session ====="
	Write-Log -Message "Script: PowerShell"
	
	# Check SSH agent and keys
	$keysLoaded = Test-SSHKeys
	if (-not $keysLoaded) {

		exit 1
	}
=======
		New-BurntToastNotification -Text $Text -AppLogo $AppLogo
	} else {
		Log-Message -Message "BurntToast module is not installed. Cannot display system notifications."
	}
}

#==============  SSH Agents checks (it's either Pageant or OpenSSH)

# Check if Pageant is running
function check-SSH {
	$processPageant = Get-Process -Name "Pageant" -ErrorAction SilentlyContinue

	if ($processPageant -ne $null) {
		# Pageant is running, continue with the script
		Log-Message -Message "Pageant is running."
	}
	elseif ($env:SSH_AUTH_SOCK -ne $null) {
		# OpenSSH agent is running

		# Check if SSH keys are loaded in OpenSSH agent
		$sshKeysLoaded = $null
		try {
			$sshKeysLoaded = ssh-add -l 2>$null
		} catch {
			# Error occurred, likely due to no keys loaded
			$sshKeysLoaded = $null
		}

		if ($sshKeysLoaded -eq $null) {
			# No keys loaded, provide a warning and exit
			$errorMessage = "OpenSSH agent is running, but no SSH keys are loaded."
			Log-Message -Message "Warning: $errorMessage"
			New-BurntToastNotification -Text "Warning: $errorMessage" -AppLogo "error.png"
			exit 1  # You can choose an appropriate exit code
		} else {
			# SSH keys are loaded in OpenSSH agent
			Log-Message -Message "SSH keys are loaded in OpenSSH agent."
		}
	}
	else {
		# Neither Pageant nor OpenSSH agent is running, exit with a warning
		$errorMessage = "Could not find any SSH Agent running. Please start an SSH agent and load your SSH keys before running this script."
		Log-Message -Message "Warning: $errorMessage"
		New-BurntToastNotification -Text "Warning: $errorMessage" -AppLogo "error.png"
		exit 1  # You can choose an appropriate exit code
	}
}


#============== Execution

try {
	
	#Start log session
	Log-Message -Message "===== New Log Session ====="
	Log-Message -Message  "Script: PowerShell"
	
	#check SSH agent
	check-SSH
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc

    # Call the Get-ExternalIP function to retrieve the external IP
    $externalIP = Get-ExternalIP

<<<<<<< HEAD
    # Log the current IP
	Write-Log -Message "Current IP: $externalIP"
    Write-Host "Current IP: $externalIP"

    # Read the old IP from the store file and Log it to console
    $oldIP = ""

    if (Test-Path -Path $ipStore) {

        $oldIP = Get-Content -Path $ipStore
		Write-Log -Message "Last logged IP: $oldIP"
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
		Write-Log -Message "$externalIP is already allowed in Webmin. Nothing to do."
        Show-BurntToastNotification -Text "$externalIP is already allowed in Webmin. Nothing to do." -AppLogo "ip.png"
        Write-Host "$externalIP is already allowed in Webmin. Nothing to do."
		# Pause execution to keep the window open (debug feature)
		# Read-Host "Press Enter to exit..."
		exit
	}
	else {
		# If the old IP doesn't exist, add the new IP to the array
		$allowIPs += $externalIP
	}
		
	# Check if preserving multiple allowed IPs is necessary
	if ($multipleIPs) {		

		# Reconstruct the 'allow=' line with the updated IP addresses
		$updatedAllowLine = "allow=" + ($allowIPs -join " ")

	} else {

=======
   # Log the current IP
	Log-Message -Message "Current IP: $externalIP"

    # Read the old IP from the store file and Log it to console
    $oldIP = ""
    if (Test-Path -Path $ipStore) {
        $oldIP = Get-Content -Path $ipStore
		# Write-Host "Last logged IP: $oldIP"
		Log-Message -Message "Last logged IP: $oldIP"
    }

	# Use Plink to check miniserv.conf content
    $miniservConfContent = Invoke-Expression -Command "$plink -ssh $sshUser@$sshHost -hostkey $hostKey -batch -P $sshPort cat $miniservConfPath"
	
	# Check if preserving multiple allowed IPs is necessary
	if ($multipleIPs) {
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
			Log-Message -Message "$externalIP is already allowed in Webmin. Nothing to do."
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
		
	} else {
		
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
		$updatedAllowLine = "allow=$externalIP"		
	}

	# Use Plink to update miniserv.conf
	$sshCommand = "sed -i 's/^allow=.*/$updatedAllowLine/' $miniservConfPath"
	Invoke-Expression -Command "$plink -ssh $sshUser@$sshHost -hostkey $hostKey -batch -P $sshPort ""$sshCommand""" | Out-Null
	
	# Show notification & log
	Show-BurntToastNotification -Text "IP address updated successfully.`nNew IP: $externalIP" -AppLogo "ip.png"
<<<<<<< HEAD
	Write-Log -Message "IP address updated successfully." 
    Write-Host "IP address updated successfully."
    
    # Restart Webmin if so specified
    if ($restartWebmin) {

        Invoke-Expression -Command "$plink -ssh $sshUser@$sshHost -hostkey $hostKey -batch -P $sshPort ""systemctl restart webmin"""
        
	    # Show notification	& Log    
		Show-BurntToastNotification -Text "Webmin restarted." -AppLogo "webmin.png"    	
		Write-Log -Message "Webmin restarted."
        Write-Host "Webmin restarted."
=======
	Log-Message -Message "IP address updated successfully." 
    
    # Restart Webmin if so specified
    if ($restartWebmin) {
        Invoke-Expression -Command "$plink -ssh $sshUser@$sshHost -hostkey $hostKey -batch -P $sshPort ""systemctl restart webmin"""        
	    # Show notification	& Log    
		Show-BurntToastNotification -Text "Webmin restarted." -AppLogo "webmin.png"    	
		Log-Message -Message "Webmin restarted."
>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
    }

    # Update the IP store file with the current IP
    $externalIP | Set-Content -Path $ipStore
<<<<<<< HEAD
	Write-Log -Message "Most recent IP added to store file."
    Write-Host "Most recent IP added to store file."

} catch {

    # Handle errors
    $errorMessage = $_.Exception.Message

    # Basically what happens if the script cannot get into SSH
    if ($errorMessage -eq "Cannot index into a null array" -or $errorMessage -like "*Unable to authenticate*" -or $errorMessage -like "*Server refused our key*" -or $errorMessage -like "*connection failed*") {

        $errorMessage = "Cannot login. Your SSH keys are probably not loaded."
        Write-Log -Message "Error: $errorMessage"
        Show-BurntToastNotification -Text "$errorMessage" -AppLogo "error.png"
        Write-Host "Error: $errorMessage"
        
        # Ask user if they want to load keys and retry
        Write-Host "Would you like to load your SSH keys and retry? (Y/N)"
        $retry = Read-Host

        if ($retry -eq "Y" -or $retry -eq "y") {

            # Try to open KeePassXC
            if ($openKeePassXC) {
                Open-KeePassXC
            }
            
            Write-Host "Please load your SSH keys in KeePassXC/Pageant."
            Read-Host "Press Enter to continue once keys are loaded"
            
            # Test if keys are now loaded
            if (Test-SSHConnection) {

                Write-Log -Message "SSH keys loaded successfully. Restarting script..."
                # Restart the script by calling it again
                & $PSCommandPath
                exit
            } else {

                $errorMessage = "SSH keys still not loaded correctly."
                Write-Log -Message "Error: $errorMessage"
                Show-BurntToastNotification -Text "$errorMessage" -AppLogo "error.png"
                Write-Host "$errorMessage" 
            }
        }

    } else {

        # Other errors
        Show-BurntToastNotification -Text "$errorMessage" -AppLogo "error.png"
        Write-Host "Error: $errorMessage"
        Write-Log -Message "Error: $errorMessage" 
    }
}

# Pause execution to keep the window open (debug feature)
# Read-Host "Press Enter to exit..."
=======
	# Write-Host "Most recent IP added to store file."
	Log-Message -Message "Most recent IP added to store file." 

} catch {
	
    # Handle errors
    $errorMessage = $_.Exception.Message
	if ($errorMessage == "Cannot index into a null array") {
		$errorMessage = "Cannot login. Your SSH keys are probably not loaded."
		}
	# Notification when there's an error
	New-BurntToastNotification -Text "$errorMessage" -AppLogo "error.png"	
	# Write-Host "Error: An error occurred: $errorMessage"
	Log-Message -Message "Error: $errorMessage" 
	
} 

# Pause execution to keep the window open (debug feature)
# Read-Host "Press Enter to exit..."

>>>>>>> 2beeb04f173cfa4150c326d5b0ed5dcfcdd661fc
