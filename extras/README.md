# Extras
This is where extra functionality scripts can be found. These are not incorporated in the main tch-gui-unhide code line, because they rely on additional packages being installed, and/or they make changes outside of the /www directory.

## tch-gui-unhide-xtra.minidlna
Replaces the stock DLNA server management in the GUI so that it supports OpenWRT minidlna.
#### Download
https://raw.githubusercontent.com/seud0nym/tch-gui-unhide/master/extras/tch-gui-unhide-xtra.minidlna
#### Prerequisites 
Install minidlna using the opkg command: `opkg install minidlna`
#### Changes External to the GUI
Creates the the following transformer UCI mappings and commit/apply scripts to support the GUI changes:
- /usr/share/transformer/commitapply/uci_minidlna.ca
- /usr/share/transformer/mappings/uci/minidlna.map

## tch-gui-unhide-xtra.samba36-server
Correctly configures OpenWRT SAMBA 3.6 and adds ability to change the password via the GUI.
#### Download
https://raw.githubusercontent.com/seud0nym/tch-gui-unhide/master/extras/tch-gui-unhide-xtra.samba36-server
#### Prerequisites
Install SAMBA v3.6 using the opkg command: `opkg --force-overwrite install samba36-server`
#### Changes External to the GUI
- Configures SAMBA to use SMBv2 by default
- Creates the samba user and group, with NO password (change the password in the GUII or with the `smbpasswd` command)
- Adds the ability to set share users via UCI and transformer
- Adds /usr/share/transformer/mappings/rpc/gui.samba.map to allow setting of password via the GUI
- Configures the default USB share to require the samba user

# How to download and execute these scripts
Download the scripts that you wish to execute into the same directory as `tch-gui-unhide`.

**NOTE: Replace `<scriptname>` with the name of the script you wish to download.**

Execute these commands on your device via a PuTTY session or equivalent (an active WAN/Internet connection is required):
```
wget https://raw.githubusercontent.com/seud0nym/tch-gui-unhide/master/extras/<scriptname> 
```

Alternatively, download the script manually and load it up to your device using WinSCP or equivalent.

After you have the script on your device, you may need to make it executable, which is done with this command (assuming you are in the same directory as the script):
```
chmod +x <scriptname>
```

These scripts will be automatically run by `tch-gui-unhide` if they exist in the directory when it is executed. They are **NOT** intended to be executed outside of `tch-gui-unhide`.
