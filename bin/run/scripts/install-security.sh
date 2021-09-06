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


loading=$(startLoading "Adding Security Scanners")
(
  sudo apt -y install clamtk clamav &>/dev/null
  cp -R -f ./bin/clamtk/* ~/.clamtk
  sudo sed -r -i "s/USERNAME/$USER/g" ~/.clamtk/cron

  sudo freshclam
  sudo mkdir -p /virusScan/quarantine
  sudo chmod 664 /virusScan/quarantine

  sudo apt -y install bleachbit &>/dev/null

  sudo apt install inotify-tools

  endLoading "$loading"
) &
runLoading "$loading"


loading=$(startLoading "Setting Up Cron Jobs")
(
  sudo mkdir -p /etc/aspiesoft-clamav-scanner
  sudo cp -R -f ./bin/aspiesoft-clamav-scanner/* /etc/aspiesoft-clamav-scanner

  sudo echo -e '#''!/bin/bash\nbash /etc/aspiesoft-clamav-scanner/start\n' | sudo tee /etc/init.d/aspiesoft-clamav-scanner
  sudo chmod +x /etc/init.d/aspiesoft-clamav-scanner
  sudo ln -s /etc/init.d/aspiesoft-clamav-scanner /etc/rc.d/aspiesoft-clamav-scanner

  bash /etc/aspiesoft-clamav-scanner/start

  endLoading "$loading"
) &
runLoading "$loading"


unset loading
