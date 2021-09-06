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


read -n1 -p "Would you like to Install The Nemo File Manager (Y/n)? " installNemoYN ; echo

read -n1 -p "Would you like to Install WINE (Y/n)? " installWineYN ; echo
if ! [ "$installWineYN" = "n" -o "$installWineYN" = "N" ] ; then
  echo "Some programs like Minecraft might not install in the proper directory, if you install WINE first"
  read -n1 -p "Would you like to Install Minecraft Java (Y/n)? " installMCYN ; echo
  read -n1 -p "Would you like to pause the installer before installing WINE, so you can install other conflicting apps (y/N)? " installWinePauseYN ; echo
fi

read -n1 -p "Would you like to Install ICE apps (Y/n)? " installIceYN ; echo
read -n1 -p "Would you like to Install Recommended Apps (Y/n)? " installRecommendedYN ; echo

if ! [ "$installMCYN" = "n" -o "$installMCYN" = "N" ] ; then
  echo "Oracle Java is recommended for Minecraft"
fi
read -n1 -p "Would you like to Install Oracle Java 16 (Y/n)? " installOracleJavaYN ; echo


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


bash ./bin/run/scripts/install-apps.sh "$installNemoYN" "$installWineYN" "$installIceYN" "$installRecommendedYN" "$installMCYN" "$installWinePauseYN"


# update
runUpdate


#clean up
unset installNemoYN
unset installWineYN
unset installIceYN
unset installRecommendedYN
unset installMCYN
unset installWinePauseYN
unset installOracleJavaYN
