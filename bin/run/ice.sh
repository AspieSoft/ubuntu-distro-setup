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


# update
runUpdate "true"


# install python
loading=$(startLoading "Installing Python")
(
  sudo apt -y install python &>/dev/null
  sudo apt -y install python3 &>/dev/null

  endLoading "$loading"
) &
runLoading "$loading"


# install ice
loading=$(startLoading "Installing ICE")
(
  sudo dpkg -i ./bin/other/ice_5.2.7_all.deb &>/dev/null
  endLoading "$loading"
) &
runLoading "$loading"


# update
runUpdate


echo -e "Done!"

#clean up
unset loading
