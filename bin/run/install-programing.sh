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
read -n1 -p "Would you like to Install ICE apps (Y/n)? " installIceYN ; echo
read -n1 -p "Would you like to Install Recommended Apps (Y/n)? " installRecommendedYN ; echo
read -n1 -p "Would you like to Install oracle java 16 (Y/n)? " installOracleJavaYN ; echo


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


# install nemo
if ! [ "$installNemoYN" = "n" -o "$installNemoYN" = "N" ] ; then
  loading=$(startLoading "Finding Nemo")
  (
    sudo apt -y install nemo &>/dev/null
    xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
    gsettings set org.gnome.desktop.background show-desktop-icons false
    gsettings set org.nemo.desktop show-desktop-icons true

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi

# install wine
if ! [ "$installWineYN" = "n" -o "$installWineYN" = "N" ] ; then
  loading=$(startLoading "Making Linux Drunk With WINE")
  (
    sudo apt -y --install-recommends install wine-stable &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi

# install ice
if ! [ "$installIceYN" = "n" -o "$installIceYN" = "N" ] ; then
  loading=$(startLoading "Installing ICE ICE Baby")
  (
    sudo dpkg -i ./bin/other/ice_5.2.7_all.deb &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


loading=$(startLoading "Installing Guake Terminal")
(
  sudo apt -y install guake &>/dev/null
  endLoading "$loading"
) &
runLoading "$loading"

loading=$(startLoading "Installing Gparted")
(
  sudo apt -y install gparted &>/dev/null
  endLoading "$loading"
) &
runLoading "$loading"


if [ "$installRecommendedYN" = "n" -o "$installRecommendedYN" = "N" ] ; then
  # clean up
  unset installNemoYN
  unset installWineYN
  unset installIceYN
  unset installRecommendedYN
  unset installOracleJavaYN
  unset loading

  exit
fi


loading=$(startLoading "Installing VLC")
(
  sudo apt -y install vlc &>/dev/null
  endLoading "$loading"
) &
runLoading "$loading"


loading=$(startLoading "Installing OBS Studio")
(
  sudo apt -y install ffmpeg &>/dev/null
  sudo apt -y install obs-studio &>/dev/null

  mkdir ~/.config/obs-studio/plugins/advanced-scene-switcher
  cp -R -f ./bin/advanced-scene-switcher/* ~/.config/obs-studio/plugins/advanced-scene-switcher

  # for new users
  mkdir /etc/skel/.config/obs-studio/plugins/advanced-scene-switcher
  cp -R -f ./bin/advanced-scene-switcher/* /etc/skel/.config/obs-studio/plugins/advanced-scene-switcher

  endLoading "$loading"
) &
runLoading "$loading"


loading=$(startLoading "Installing Atom Text Editor")
(
  sudo snap install --classic atom &>/dev/null

  cp -R -f ./bin/atom/* ~/.atom

  # for new users
  cp -R -f ./bin/atom/* /etc/skel/.atom

  endLoading "$loading"
) &
runLoading "$loading"


loading=$(startLoading "Installing VSCode")
(
  sudo snap install --classic code &>/dev/null

  code --install-extension Shan.code-settings-sync &>/dev/null

  # for new users
  mkdir -p /etc/skel/.vscode/extensions
  cp -R -f ~/.vscode/extensions/* /etc/skel/.vscode/extensions

  endLoading "$loading"
) &
runLoading "$loading"


loading=$(startLoading "Installing Blender")
(
  sudo snap install --classic blender &>/dev/null
  endLoading "$loading"
) &
runLoading "$loading"

loading=$(startLoading "Installing Pinta")
(
  sudo apt -y install pinta &>/dev/null
  endLoading "$loading"
) &
runLoading "$loading"


# update
runUpdate


# clean up
unset installNemoYN
unset installWineYN
unset installIceYN
unset installRecommendedYN
unset installOracleJavaYN
unset loading
