This Powershell and Bash script automatically changes the allowed IP on [Webmin](https://github.com/webmin/webmin), depending on the dynamic IP assigned to the machine you are connecting from.

If you connect to your Webmin/Virtualmin instance remotely (for example on a VPS) from a **dynamic IP** or changing **VPN**, read on.

## Why this script

On Webmin, you can decide to <ins>allow connections only from selected ip numbers or hostnames</ins>. 
This is a great security feature, however useless if you have a dynamic IP, like most people do, or if you use a random VPN machine to connect.

Previously, to make use of this feature you'd have to subscribe to a DDNS service such as Dynu or NoIP, have them associate a given hostname to your current IP number, and set up Webmin to only allow that particular hostname.

This is a solution replete with problems, as it relies on one company's good will to provide you with this free service for times to come. 
Furthermore, most likely it means allowing their app to always run in the background on your machine, in order to monitor your IP changes.

Not anymore.

## What this script does:
1) It discovers your IP number against a free IP service such as Icanhazip or ipify;
2) Connects to your remote server, retrieve the `/etc/webim/miniserv.conf` file Webmin uses for settings;
3) Checks whether the `allow=` line already contains your current IP number (if yes, exit the script);
4) If not, modifies it so that the IP number is current (it will append the current IP to the list, if multiple IPs/Hostnames are allowed, removing the previous dynamic IP number);
5) Restarts Webmin.

## Requirements
On Windows, this script connects to your server via SSH using Plink (part of the [Putty](https://www.chiark.greenend.org.uk/~sgtatham/putty/) package).
Therefore, it requires you to:
1) Have Putty present on your machine;
2) Customize the script, providing the path to the Plink executable (if not in `$PATH`, or the script directory);
3) If you want the script to send a system notification when the IP has been changed, you need to make sure the [BurntToast](https://github.com/Windos/BurntToast) extension to PowerShell is installed.
4) To run a PowerShell script on Windows, you need to set Execution Policy in PowerShell, using this command: `Set-ExecutionPolicy RemoteSigned` as Administrator.

Furthermore, whether you are on Windows or Linux, you will have to customize the script, providing:
   - Path to the `miniserv.conf` file (usually `/etc/webmin/miniserv.conf`)
   - IP number/hostname of remote server
   - username (user shoud have write privileges to `miniserv.conf`)
   - SSH port (usually `22`)
   - Host Key public fingerprint (in the `key-type:host-key` format; can be retrieved via SSH or from within Webmin SSH server settings. The host public key honestly is not always necessary, once it is saved in the SSH cache. I've found this to be a requirement only under Windows, and probably only the first time the script runs.)

Most importantly, it is essential that you have **a running SSH agent** (such as Pageant under Windows, also included in Putty) with the respective SSH-RSA key loaded for the user[^1]. 
(I assume you don't want to write down sensitive credentials inside this script.)

## Installation
1) [Download](https://github.com/unalignedcoder/webmin-ip-update/releases) the script
2) Place it wherever is convenient for you (best kept in its own folder, as it will create a small file when in use)
3) Set up a cron/scheduled task to run this script in the background whenever you deem necessary (it could run every half hour, once a day, it could be ran only when connecting to the internet, etc.)
4) Alternatively, you could run the script **manually** whenever you are about to connect to Webmin.

## Portability
The script is "portable". It will write one necessary file into its own directory (this file can be shared between the PowerShell and Bash scripts), and will look for icons for the notifications within the same directory. By keeping all the files in their own folder, the script can work from any machine.

[^1]:  Under both Windows and Linux, it can be a good idea to use a program such as [KeepassXC](https://github.com/keepassxreboot/keepassxc) to load SSH keys onto your SSH agent, so that they will be available only when you are logged into the Keepass database.
