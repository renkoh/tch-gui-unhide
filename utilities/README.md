# Utility Scripts
A collection of utility scripts for your Technicolor router.

## de-telstra
This script applies most of the hardening recommendations from https://hack-technicolor.readthedocs.io/en/stable/Hardening/. 

In addition, it automatically:
- Overwrites the */etc/dropbear/authorized_keys* file with either:
    - the contents of an *authorized_keys* file found in the directory from which the script is invoked; or
    - an empty file (to remove any ISP default public keys)
- Correctly enables SSH LAN access
- Disables and removes CWMP
- Disables and removes all Telstra monitoring and logging
- Disables and removes Telstra AIR, including the SSIDs and GUI card
- Removes web GUI default user access
- Sets SAMBA and DLNA hostnames to the device hostname (replacing Telstra-Modem)
- Removes packages related to CWMP, Telstra monitoring, and Telstra AIR

Optionally, it can also:
- Set the hostname of the device and the domain of the LAN. Default Telstra hostnames (except telstra.wifi, which is used by EasyMesh) are removed.
- Set the device DNS servers
- Disable or enable content and printer sharing, and the DLNA server
- Disable or enable all ALGs (FTP, TFTP, SNMP, PPTP, IRC, AMANDA, RTSP, SIP)
- Disable or enable telephony, and enables VoLTE backup voice service and SMS reception
- Disable or enable DECT Emission Mode
- Disable or enable UPnP
- Disable or enable power saving
- Disable or enable MultiAP (EasyMesh) if it is installed on the device
- Disable or enable WPS on non-Guest and non-Backhaul SSIDs 
- Configure the opkg package manager so that you can install additional packages on the device

It does NOT remove the hidden BH-xxxxxx SSID from the DJA0230 or DJA0231, as this is not related to Telstra AIR. It is the wireless backhaul for EasyMesh.

This script accepts the following options:
```
 -h u|d|s|<hostname>
    where u            Leave hostname unchanged (Default)
          d            Set the hostname to the hardware variant (e.g.DJA0231 or TG800vac)
          s            Set the hostname to hardware variant and appends the device serial number (Useful if you have multiple devices of the same variant.)
          <hostname>   Use the specified hostname
 -d u|g|<domainname>
    where u            Leave domain name unchanged (Default)
          g            Set the domain name to gateway
          <domainname> Set the domain name to <domainname>
 -n u|a|c|g|f|o|<n.n.n.n>
    where u            Leave DNS servers unchanged (Default)
          a            Automatically use the DNS servers from the ISP (device default)
          c            Set the DNS servers to Cloudflare
          g            Set the DNS servers to Google
          f            Set the DNS servers to OpenDNS Family Shield
          o            Set the DNS servers to OpenDNS
          <n.n.n.n>    Set the DNS servers to 1 or 2 comma-separated IPv4 addresses (e.g. 8.8.8.8,1.1.1.1)
 -a u|y|n
    where u            Leave ALGs unchanged (Default)
          y            Enable ALGs (device default)
          n            Disable ALGs (except SIP if telephony enabled)
 -c u|y|n
    where u            Leave Content Sharing unchanged (Default)
          y            Enable Content Sharing (device default)
          n            Disable Content Sharing
 -f u|y|n
    where u            Leave File Sharing unchanged (Default)
          y            Enable File Sharing (device default)
          n            Disable File Sharing
 -p u|y|n
    where u            Leave power saving unchanged (Default)
          y            Enable power saving (device default)
          n            Disable power saving
 -r u|y|n
    where u            Leave Printer Sharing unchanged (Default)
          y            Enable Printer Sharing (device default)
          n            Disable Printer Sharing
 -t u|y|n
    where u            Leave Telephony (mmpbx) unchanged (Default)
          y            Enable the telephony service
          n            Disable the telephony service
 -e u|y|n
    where u            Leave DECT Emission Mode unchanged (Default)
          y            Enable DECT Emission Mode (device default)
          n            Disable DECT Emission Mode
 -u u|y|n
    where u            Leave UPnP unchanged (Default)
          y            Enable the UPnP service
          n            Disable the UPnP service
 -m u|y|n
    where u            Leave EasyMesh (multiap) unchanged (Default)
          y            Enable EasyMesh (multiap) (device default)
          n            Disable EasyMesh (multiap)
 -w u|y|n              
    where u            Leave WPS unchanged on non-Guest and non-Backhaul SSIDs (Default)
          y            Enable WPS on non-Guest and non-Backhaul SSIDs (device default)
          n            Disable WPS on non-Guest and non-Backhaul SSIDs
 -o                    Configures opkg
 -A                    Equivalent to: -hd -dg -an -cn -fn -rn -un -wn
 -S                    Equivalent to: -hs -dg -an -cn -fn -rn -un -wn
 -R                    Reset to device defaults (equivalent to: -hmymodem -dmodem -na -ay -cy -fy -my -py -ry -ty -ey -uy -wy)
 -U                    Check for and download the latest version from GitHub
```
Note that the options to disable/enable EasyMesh are only applicable to devices with multiap installed.

## dumaos
Enables or disables DumaOS on a DJA0231 running the 18.1.c.0514 or later firmware, or a DJA0230 running 18.1.c.0549 or later. It also disables or enables reboot on core dump, because if DumaOS gets into trouble, the router will just continally reboot.

This script supports 1 parameter: `-on` or `-off`
- -on
    - Enables DumaOS and disables reboot on core dump, then starts the DumaOS service.
- -off
    - Disables DumaOS and enables reboot on core dump, then stops the DumaOS service.

If you enable DumaOS *after* running the `tch-gui-unhide` script, you will need to re-run `tch-gui-unhide` to enable the button to access DumaOS. Similarly, if you disable DumaOS, you will need to re-run `tch-gui-unhide` to remove the button. 

## reset-to-factory-defaults-with-root
It does what it says. It is a copy of the commands from https://hack-technicolor.readthedocs.io/en/stable/Upgrade/#preserving-root-access (without the backup - you need to do that manually and move it off the device), with a confirmation prompt and immediate reboot.

This script also supports the following optional parameters:
- -f filename
  - Flash 'filename' into the mounted bank after reset and before reboot
  - 'filename" can either be an unpacked file (.bin) or a .rbi file. 
  - A .rbi file will be unpacked to either USB drive (by default) or /tmp before flashing.
- -b
  - Make a full backup of your booted bank configuration (requires attached USB device)
- -i
  - Keep the existing LAN IP address after reset and reboot
- -I n.n.n.n
  - Use LAN IP address n.n.n.n after reset and reboot
- -c
  - Disable CWMPD configuration during first boot after reset
- -n
    - Do NOT reboot.

## set-optimal-bank-plan
Again, it does what it says. It is a copy of the commands from https://hack-technicolor.readthedocs.io/en/stable/Hacking/PostRoot/#bank-planning, with a confirmation prompt.

## set-web-admin-password
Allows you to set or reset the web admin password. Specify the new password as the first parameter.

## show-bank-plan
A pretty version of `find /proc/banktable -type f -print -exec cat {} ';'`, with a final analysis to show whether the bank plan is optimal, or not.

Example output:
```
/proc/banktable/active         : bank_1  OK
/proc/banktable/activeversion  : Unknown
/proc/banktable/booted         : bank_2  OK
/proc/banktable/bootedoid      : 5ed62a9e7b9c275f18e900f4
/proc/banktable/inactive       : bank_2
/proc/banktable/notbooted      : bank_1
/proc/banktable/notbootedoid   : Unknown
/proc/banktable/passiveversion : 18.1.c.0514-2881009-20200602123158-44c5de58631202876d970bdcc184a6c2dc8ef375

Bank Plan is OPTIMAL
```
## transformer-cli
Version 17 firmwares do not include `/usr/bin/transformer-cli`, which is very useful for working out what is returned in the various GUI scripts.

## unpack-rbi
Unpacks the *.rbi* file passed as the first parameter. The second parameter is optional, and is either a filename or directory to which the *.rbi* file will be unpacked. If the filename or directory is specified, the file will be written to the /tmp directory with the same name but with an extension of *.bin*.

# How to download and execute these scripts
If you download a tch-gui-unhide release archive, the scripts applicable to that firmware version are included.

You can also download the latest version individually:

**NOTE: Replace `<scriptname>` with the name of the script you wish to download.**

Execute this command on your device via a PuTTY session or equivalent (an active WAN/Internet connection is required):
```
wget https://raw.githubusercontent.com/seud0nym/tch-gui-unhide/master/utilities/<scriptname> 
```

Alternatively, download the script manually and load it up to your device using WinSCP or equivalent.

After you have the script on your device, you may need to make it executable, which is done with this command (assuming you are in the same directory as the script):
```
chmod +x <scriptname>
```

Then, execute the script (assuming you are in the same directory into which you downloaded or uploaded the script):
```
./<scriptname> <options>
```
