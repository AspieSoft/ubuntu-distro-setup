#!/bin/bash

installNemoYN="$1"
installWineYN="$2"
installIceYN="$3"
installRecommendedYN="$4"
installMCYN="$5"
installWinePauseYN="$6"

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


# add repositories
loading=$(startLoading "Adding Repositorys")
(
  sudo add-apt-repository -y multiverse &>/dev/null
  sudo apt-add-repository -y universe &>/dev/null
  sudo add-apt-repository -y ppa:obsproject/obs-studio &>/dev/null
  sudo add-apt-repository -y ppa:cybermax-dexter/sdl2-backport &>/dev/null
  sudo add-apt-repository -y ppa:pinta-maintainers/pinta-stable &>/dev/null
  endLoading "$loading"
) &
runLoading "$loading"


# update
loading=$(startLoading "Updating")
(
  sudo apt update &>/dev/null
  endLoading "$loading"
) &
runLoading "$loading"


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

if ! [ "$installMCYN" = "n" -o "$installMCYN" = "N" ] ; then
  loading=$(startLoading "Installing Minecraft Java")
  (
    sudo wget -q -O bin/Minecraft.deb https://launcher.mojang.com/download/Minecraft.deb &>/dev/null
    sudo dpkg -i ./bin/Minecraft.deb &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi
nemo
if [ "$installWinePauseYN" = "y" -o "$installWinePauseYN" = "Y" ] ; then
  echo "Install any software that may conflict with WINE"
  read -n1 -r -s -p "Press any key to continue..." ; echo
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
  sudo dpkg -i ./bin/ice_5.2.7_all.deb &>/dev/null

  endLoading "$loading"
  ) &
  runLoading "$loading"
fi


# install other apps

loading=$(startLoading "Installing Guake Terminal")
(
  sudo apt -y install guake &>/dev/null
  endLoading "$loading"
) &
runLoading "$loading"

loading=$(startLoading "Installing Gnome Tweak Tool")
(
  sudo apt -y install gnome-tweak-tool &>/dev/null
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
  unset installMCYN
  unset installWinePauseYN
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


loading=$(startLoading "Installing Steam")
(
  sudo apt -y install steam &>/dev/null
  endLoading "$loading"
) &
runLoading "$loading"


# clean up
unset installNemoYN
unset installWineYN
unset installIceYN
unset installRecommendedYN
unset installMCYN
unset installWinePauseYN
unset loading
