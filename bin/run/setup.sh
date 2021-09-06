#!/bin/bash

function startLoading() {
  local tempVar=$(mktemp) && echo "false" > $tempVar
  #bash ./bin/run/scripts/loading.sh "$tempVar" "$1..." &
  echo "$tempVar" "$1"
  unset tempVar
}

function runLoading() {
  local path=$(echo "$1" | cut -d' ' -f1)
  local msg="${1#* }"
  bash ./bin/run/scripts/loading.sh "$path" "$msg..."
}

function endLoading() {
  local path=$(echo "$1" | cut -d' ' -f1)
  local msg="${1#* }"
  echo "true" > $path
  #sudo rm -rf $path
  echo -e "\r$msg    \n"
  unset path
  unset msg
}

function runUpdate() {
  local loading=$(startLoading "Updating")
  (
    sudo apt update &>/dev/null
    if [ "$1" = "true" ] ; then
      sudo apt upgrade -y &>/dev/null
    fi
    endLoading "$loading"
  ) &
  runLoading "$loading"
  unset loading
}


# To log into sudo with password prompt
sudo echo


# Get user input for GRUB_TIMEOUT (not making them wait for the script to get half way through)
read -p "What do you want to set the grub time to (1-30 Seconds)? " inputTime
if [ -n "$inputTime" ] && ! [ "$inputTime" -eq "$inputTime" ] 2>/dev/null; then
  inputTime=5
fi
if [ $inputTime -lt 1 ] ; then
  inputTime=1
fi
if [ $inputTime -gt 30 ] ; then
  inputTime=30
fi

echo -e "$inputTime\n"


# ask user about other installs
read -n1 -p "Would you like to fix potential dual monitor issues with nvidia (Y/n)? " fixDualMonitorYN ; echo
read -n1 -p "Would you like to Install The Nemo File Manager (Y/n)? " installNemoYN ; echo

read -n1 -p "Would you like to Install WINE (Y/n)? " installWineYN ; echo
if ! [ "$installWineYN" = "n" -o "$installWineYN" = "N" ] ; then
  echo "Some programs like Minecraft might not install in the proper directory, if you install WINE first"
  read -n1 -p "Would you like to Install Minecraft Java (Y/n)? " installMCYN ; echo
  read -n1 -p "Would you like to pause the installer before installing WINE, so you can install other conflicting apps (y/N)? " installWinePauseYN ; echo
fi

read -n1 -p "Would you like to Install ICE (Y/n)? " installIceYN ; echo
read -n1 -p "Would you like to Install Recommended Apps (Y/n)? " installRecommendedYN ; echo

if ! [ "$installMCYN" = "n" -o "$installMCYN" = "N" ] ; then
  echo "Oracle Java is recommended for Minecraft"
fi
read -n1 -p "Would you like to Install Oracle Java 16 (Y/n)? " installOracleJavaYN ; echo

read -n1 -p "Would you like to run a ClamAV Virus Scan afterwards (Y/n)? " runVirusScanYN ; echo


# enable firewall
loading=$(startLoading "Enabling Firewall")
(
  sudo ufw enable &>/dev/null
  endLoading "$loading"
) &
runLoading "$loading"

# update
runUpdate "true"


# install browsers
bash ./bin/run/scripts/install-browsers.sh

# install programing languages
bash ./bin/run/scripts/install-languages.sh "$installOracleJavaYN"

# install extras
bash ./bin/run/scripts/install-extras.sh


# update
runUpdate


# modify grub menu timeout
loading=$(startLoading "Editing Grub Menu")
(
  cp -n /etc/default/grub /etc/default/grub-backup

  sudo sed -r -i 's/^GRUB_TIMEOUT_STYLE=(.*)$/GRUB_TIMEOUT_STYLE=menu/gm' /etc/default/grub
  sudo sed -r -i "s/^GRUB_TIMEOUT=(.*)\$/GRUB_TIMEOUT=$inputTime/gm" /etc/default/grub

  sudo update-grub

  endLoading "$loading"
) &
runLoading "$loading"


# upgrade preformance
bash ./bin/run/scripts/upgrade.sh


# fix common issues
bash ./bin/run/scripts/fix.sh "$fixDualMonitorYN"


# update
runUpdate


# install apps
bash ./scripts/install-apps.sh "$installNemoYN" "$installWineYN" "$installIceYN" "$installRecommendedYN" "$installMCYN" "$installWinePauseYN"

# install security apps
bash ./scripts/install-security.sh


# update
runUpdate "true"


# clean ubuntu
loading=$(startLoading "Cleaning Up")
(
  sudo apt -y clean &>/dev/null
  sudo apt -y autoremove &>/dev/null
  sudo apt update &>/dev/null

  # unset variables
  unset inputTime
  unset fixDualMonitorYN
  unset installNemoYN
  unset installWineYN
  unset installIceYN
  unset installRecommendedYN
  unset installMCYN
  unset installWinePauseYN
  unset installOracleJavaYN

  endLoading "$loading"
) &
runLoading "$loading"
unset loading

echo "Done!"


# run virus scan
if [ "$runVirusScanYN" = "n" -o "$runVirusScanYN" = "N" ] ; then
  unset runVirusScanYN
  exit
fi
unset runVirusScanYN

# run virus scan
bash ./bin/run/scripts/scan.sh "/"


# update
runUpdate


echo
read -n1 -r -p "Press any key to exit..." ; echo

exit
