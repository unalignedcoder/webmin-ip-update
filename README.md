This script automatically changes the allowed IP on [Webmin](https://github.com/webmin/webmin), depending on the dynamic IP assigned to the machine you are connecting from.

It is available in [PowerShell](https://github.com/unalignedcoder/webmin-ip-update/blob/main/webmin-ip-update.ps1) and [Bash](https://github.com/unalignedcoder/webmin-ip-update/blob/main/webmin-ip-update.sh).

## Why this script
If you are a single user/admin who connects to your Webmin/Virtualmin instance remotely (for example on a VPS), this script is for you.

On Webmin, you can decide to allow connections only from selected ip numbers or hostnames. 
This is a great security feature, however useless if you have a dynamic IP, like most people do.

Previously, to overcome this problem you had to subscribe to a DDNS service such as Dynu or NoIP, have them associate a given hostname to your current IP number, and set up Webmin to only allow that particular hostname.

This is a solution replete with problems, as it relies on some company's good will to provide you with this free service for times to come. 
Furthermore, most likely it means allowing their app to always run in the background on your machine, in order to monitor your IP changes. Or otherwise it requires you to modify your router settings.

Not anymore.

## What this script does:
1) It will discover your IP number against a free DNS service such as OpenDNS or Google;
2) Connect to your remote server, retrieve the `/etc/webim/miniserv.conf` file Webmin uses for settings;
3) Check whether the `allow=` line already contains your current IP number;
4) If not, modify it so that the IP number is current (it will append the current IP to the list, if multiple IPs/Hostnames are allowed, but always deleting the previous dynamic IP number from the local machine.).

By so doing, it will be possible to log onto your webmin/virtualmin frontend *only from your machine*.

## Requirements
On Windows, this script connects to your server via SSH using Plink (part of the [Putty](https://www.chiark.greenend.org.uk/~sgtatham/putty/) package).
Therefore, it requires you to:
1) Have Putty present on your machine;
2) Customize the script, providing the path to the Plink executable (if not in `$PATH`);
3) If you want the script to send a system notification when the IP has been changed, you need to make sure the [BurntToast](https://github.com/Windos/BurntToast) extension to PowerShell is installed.

Furthermore, whether you are on Windows or Linux, you will have to customize the script, providing:
   - Path to the `miniserv.conf` file (usually `/etc/webmin/miniserv.conf`)
   - IP number/hostname of remote server
   - username (user shoud have write privileges to `miniserv.conf`)
   - SSH port (usually `22`, a custom port is recommended)
   - Host Key public fingerprint (in the `key-type:host-key` format; can be retrieved via SSH or from within Webmin SSH server settings)

Most importantly, it is essential that you have **a running SSH agent** (such as Pageant under Windows, also included in Putty) with the respective SSH-RSA key loaded for the user[^1]. 
(I assume you don't want to write down sensitive credentials inside this script.)

## Installation
1) Download the script
2) Place it wherever is convenient for you
3) Set up a cron/scheduled task to run this script in the background whenever you deem necessary (it could run every half hour, once a day, it could be ran only when connecting to the internet, etc.)
4) Alternatively, you could run the script **manually** whenever you are about to connect to Webmin. A simple script could be concocted  to first run this script, then open the Webmin frontend in the default browser.

For example, a .bat file under Windows could achieve this:
```
@echo off
:: Run your PowerShell script
powershell.exe -ExecutionPolicy Bypass -File "C:\path\to\your\script.ps1"

:: Open Webmin in the default browser
start "" "https://remote.server:10000"
```

[^1]:  Under both Windows and Linux, it can be a good idea to use a program such as [KeepassXC](https://github.com/keepassxreboot/keepassxc) to load SSH keys onto your SSH agent, so that they will be available only when you are logged into the Keepass database.
