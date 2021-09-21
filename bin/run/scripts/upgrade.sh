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


# preformance upgrades
loading=$(startLoading "Upgrading preformance")
(
  sudo apt -y install preload &>/dev/null
  sudo add-apt-repository -y ppa:linrunner/tlp &>/dev/null
  sudo apt -y update &>/dev/null
  sudo apt -y install tlp tlp-rdw &>/dev/null
  sudo systemctl enable tlp &>/dev/null
  sudo tlp start &>/dev/null

  endLoading "$loading"
) &
runLoading "$loading"


# boot time improvements
loading=$(startLoading "Disabling time wasting startup programs")
(
  sudo systemctl disable postfix.service &>/dev/null # for email server
  sudo systemctl disable NetworkManager-wait-online.service &>/dev/null # wastes time connectiong to wifi
  sudo systemctl disable networkd-dispatcher.service &>/dev/null # depends on the time waster above
  sudo systemctl disable systemd-networkd.service &>/dev/null # depends on the time waster above
  sudo systemctl disable accounts-daemon.service &>/dev/null # is a potential securite risk
  sudo systemctl disable debug-shell.service &>/dev/null # opens a giant security hole
  sudo systemctl disable pppd-dns.service &>/dev/null # dial-up internet (its way outdated)

  sudo systemctl disable whoopsie.service &>/dev/null # ubuntu error reporting

  # todo: see if "cups.service" can be delayed
  # todo: see if "snapd.service" can be delayed (takes 2 seconds at boot)
  # todo: see if "plymouth-quit-wait.service" can be delayed or disabled (takes 7 seconds at boot)
  # todo: see if "dev-sdc3.device" can be delayed or disabled (takes 12 seconds at boot)

  #sudo nano /etc/default/grub
  #GRUB_CMDLINE_LINUX_DEFAULT="noplymouth video=SVIDEO-1:d"
  #sudo update-grub

  endLoading "$loading"
) &
runLoading "$loading"


loading=$(startLoading "Improving multitasking preformance")
(
  sudo cp ./bin/other/set-ram-limit.sh /etc/init.d/set-ram-limit
  sudo chmod +x /etc/init.d/set-ram-limit

  sudo update-rc.d set-ram-limit defaults
  sudo service set-ram-limit start

  bash ./bin/other/set-ram-limit.sh

  endLoading "$loading"
) &
runLoading "$loading"


unset loading
