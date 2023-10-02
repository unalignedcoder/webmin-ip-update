Script which automatically changes the allowed IP on [Webmin](https://github.com/webmin/webmin), depending on the dynamic IP assigned to the machine you are connecting from.

It is available in both the **PowerShell** and **Bash** flavors, so as to be used under Windows and Linux with equal results.

## Why this script
If you are a single user/admin who connects to your Webmin/Virtualmin instance remotely (for example on a VPS), this script is for you.

On Webmin, you can decide to allow connections only from selected ip numbers or hostnames. 
This is a great security feature, however useless if you have a dynamic IP, like most people do.

Previously, to overcome to this problem you had to subscribe to a DDNS service such as Dynu or NoIP, have them associate a given hostname to your current IP number, and set up Webmin to only allow that particular hostname.

This is a solution replete with problems, as it relies on some company's good will to provide you with this free service for times to come. 
Furthermore, most likely allowing their app to always run in the background on your machine to monitor your IP changes.

Not anymore.

## What this script does:
1) It will discover your IP number against a free DNS service such as OpenDNS or Google;
2) Connect to your remote server, retrieve the `/etc/webim/miniserv.conf` file Webmin uses for settings;
3) Check whether the `allow=` line already contains your current IP number;
4) If not, modify it so that the IP number is current.

By so doing, it will be possible to log onto your webmin/virtualmin frontend *only from your machine*.

## Requirements
This script connects to your server via SSH using Plink (part of the [Putty](https://www.chiark.greenend.org.uk/~sgtatham/putty/) package).
Therefore, it requires you to provide:
1) IP number/hostname of remote server
2) username
3) SSH port (usually 22)
4) Host Key fingerprint
5) A running agent (such as Pageant under Windows) with the SSH-RSA key loaded for the user

## Installation
Just download the script, place it wherever is convenient for you, and set up a cron/scheduled task to run this script in the background whenever you deem necessary.
It could run every half hour, once a day, it could be ran only when connecting to the internet, etc.

Or else, you could run it **manually** whenever you are about to connect to Webmin. 
A simple script could be concocted  to first run this script, then open the Webmin frontend in the default browser.
