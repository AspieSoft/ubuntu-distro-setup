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

  endLoading "$loading"
) &
runLoading "$loading"

unset loading
