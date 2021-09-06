#!/bin/bash

installOracleJavaYN="$1"

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


# install java
loading=$(startLoading "Installing Java")
(
  sudo apt -y install openjdk-8-jre &>/dev/null
  sudo apt -y install openjdk-8-jdk &>/dev/null

  if ! [ "$installOracleJavaYN" = "n" -o "$installOracleJavaYN" = "N" ] ; then
    sudo add-apt-repository -y ppa:linuxuprising/java &>/dev/null
    sudo apt update &>/dev/null
    sudo apt -y install oracle-java16-installer --install-recommends &>/dev/null
  else
    sudo apt -y install openjdk-11-jre &>/dev/null
    sudo apt -y install openjdk-11-jdk &>/dev/null
  fi

  endLoading "$loading"
) &
runLoading "$loading"

sudo update-alternatives --config java


# install python
loading=$(startLoading "Installing Python")
(
  sudo apt -y install python &>/dev/null
  sudo apt -y install python3 &>/dev/null

  endLoading "$loading"
) &
runLoading "$loading"


# install node.js
loading=$(startLoading "Installing Node.js")
(
  sudo apt -y install curl dirmngr apt-transport-https lsb-release ca-certificates &>/dev/null
  curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
  sudo apt -y install nodejs &>/dev/null
  sudo apt -y  install gcc g++ make &>/dev/null

  endLoading "$loading"
) &
runLoading "$loading"


# install npm
loading=$(startLoading "Installing NPM")
(
  sudo apt -y install npm &>/dev/null
  npm config set prefix ~/.npm
  echo 'export N_PREFIX="$HOME/.npm"' >> ~/.zshrc
  echo 'export N_PREFIX="$HOME/.npm"' >> ~/.profile
  sudo npm install -g npm &>/dev/null

  sudo chown -R $(whoami) ~/.npm

  endLoading "$loading"
) &
runLoading "$loading"


# install yarn
loading=$(startLoading "Installing YARN")
(
  sudo apt -y install yarn &>/dev/null

  endLoading "$loading"
) &
runLoading "$loading"


# install git
loading=$(startLoading "Installing GIT")
(
  sudo apt -y install git &>/dev/null
  endLoading "$loading"
) &
runLoading "$loading"

unset loading
