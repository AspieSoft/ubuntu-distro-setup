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


read -n1 -p "Would you like to run a ClamAV Virus Scan (Y/n)? " runVirusScanYN ; echo


# enable firewall
loading=$(startLoading "Enabling Firewall")
(
  sudo ufw enable &>/dev/null
  endLoading "$loading"
) &
runLoading "$loading"

# update
runUpdate "true"


# install security apps
bash ./bin/run/scripts/install-security.sh

# update
runUpdate "true"


# clean ubuntu
loading=$(startLoading "Cleaning Up")
(
  sudo apt -y clean &>/dev/null
  sudo apt -y autoremove &>/dev/null
  sudo apt update &>/dev/null

  endLoading "$loading"
) &
runLoading "$loading"
unset loading


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
