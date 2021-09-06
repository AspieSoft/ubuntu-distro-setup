#!/bin/bash

echo "Welcome To AspieSoft's Recommended Ubuntu Distro Setup!"


function main(){

  echo
  echo "[0] Exit"
  echo "[1] Setup Everything"
  echo "[2] Install WINE"
  echo "[3] Install ICE"
  echo "[4] Secure Distro"
  echo "[5] Run Virus Scan"
  echo "[6] Fix Common Issues"
  echo "[7] Upgrade Preformance"
  echo "[8] Install Programing Languages"
  echo "[9] Install Programer Tools"
  echo "[10] Install All Apps"
  echo
  read -p "What would you like to do? " input

  if [ -z "$input" ] ; then
    exit
  fi

  if [ "$input" -eq "0" ] ; then
    exit
  elif [ "$input" -eq "1" ] ; then
    bash ./bin/run/setup.sh
  elif [ "$input" -eq "2" ] ; then
    bash ./bin/run/wine.sh
  elif [ "$input" -eq "3" ] ; then
    bash ./bin/run/ice.sh
  elif [ "$input" -eq "4" ] ; then
    bash ./bin/run/secure.sh
  elif [ "$input" -eq "5" ] ; then
    bash ./bin/run/scan.sh
  elif [ "$input" -eq "6" ] ; then
    bash ./bin/run/fix.sh
  elif [ "$input" -eq "7" ] ; then
    bash ./bin/run/upgrade.sh
  elif [ "$input" -eq "8" ] ; then
    bash ./bin/run/install-languages.sh
  elif [ "$input" -eq "9" ] ; then
    bash ./bin/run/install-programing.sh
  elif [ "$input" -eq "10" ] ; then
    bash ./bin/run/install-apps.sh
  else
    exit
  fi

  main
}

main
