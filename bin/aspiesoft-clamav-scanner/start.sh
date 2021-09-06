#!/bin/bash

# bash ./scan-downloads.sh "$HOME/Downloads"
# bash ./scan-downloads.sh "$HOME/Documents"
# bash ./scan-downloads.sh "$HOME/Desktop"
# bash ./scan-downloads.sh "$HOME/Pictures"
# bash ./scan-downloads.sh "$HOME/Videos"

bash ./scan-downloads.sh "/home"


# cron job

# 0 0 * * * sudo clamscan -r --bell --move="/virusScan/quarantine" --exclude-dir="/virusScan/quarantine" --exclude-dir="/home/$USER/.clamtk/viruses" --exclude-dir="smb4k" --exclude-dir="/run/user/$USER/gvfs" --exclude-dir="/home/$USER/.gvfs" --exclude-dir=".thunderbird" --exclude-dir=".mozilla-thunderbird" --exclude-dir=".evolution" --exclude-dir="Mail" --exclude-dir="kmail" --exclude-dir="^/sys" /

crontab -l | { cat; echo '0 2 * * * sudo clamscan -r --bell --move="/virusScan/quarantine" --exclude-dir="/virusScan/quarantine" --exclude-dir="/home/$USER/.clamtk/viruses" --exclude-dir="smb4k" --exclude-dir="/run/user/$USER/gvfs" --exclude-dir="/home/$USER/.gvfs" --exclude-dir=".thunderbird" --exclude-dir=".mozilla-thunderbird" --exclude-dir=".evolution" --exclude-dir="Mail" --exclude-dir="kmail" --exclude-dir="^/sys" / # aspiesoft-clamav-scan'; } | crontab -
