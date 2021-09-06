#!/bin/bash

fixDualMonitorYN="$1"

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


loading=$(startLoading "Fixing potential dual monitor issues")
(
  # fix potential duel monitor issues
  if ! [ "$fixDualMonitorYN" = "n" -o "$fixDualMonitorYN" = "N" ] ; then
    sudo apt -y install xserver-xorg-video-nouveau &>/dev/null
    sudo apt -y purge nvidia* &>/dev/null
    sudo apt -y install xserver-xorg-video-nouveau &>/dev/null
  fi

  # fix lockscreen monitor
  sudo cp ~/.config/monitors.xml ~gdm/.config/

  endLoading "$loading"
) &
runLoading "$loading"


loading=$(startLoading "Fixing other issues")
(
  # hide snap folder
  if ! grep -q snap ~/.hidden ; then
    echo snap >> ~/.hidden
  fi

  # hide snap folder for new users
  if ! sudo grep -q snap /etc/skel/.hidden ; then
    echo snap | sudo tee -a /etc/skel/.hidden &>/dev/null
  fi

  endLoading "$loading"
) &
runLoading "$loading"


unset loading
