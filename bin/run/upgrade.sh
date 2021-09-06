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


# update
runUpdate "true"


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


# update
runUpdate


# clean up
unset inputTime
unset loading
