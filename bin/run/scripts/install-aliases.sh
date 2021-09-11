#!/bin/bash

addYumAlias="$1"

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


loading=$(startLoading "Installing Custom Aliases")
(

  if sudo grep -q "# AspieSoft Added Aliases" /etc/bash.bashrc ; then
    # todo: fix isue where this is not removed (regex failed)
    sudo sed -r -i -z "s/# AspieSoft Added Aliases - START\r?\n([\r\n]|.)*?\r?\n# AspieSoft Added Aliases - END//m" /etc/default/grub &>/dev/null
  else
    sudo cp /etc/bash.bashrc /etc/bash.bashrc-backup &>/dev/null
  fi


  echo -e "\n# AspieSoft Added Aliases - START\n" | sudo tee -a /etc/bash.bashrc &>/dev/null

  sudo cat ./bin/other/install-aliases.sh | sudo tee -a /etc/bash.bashrc &>/dev/null

  if ! [ "$addYumAlias" = "n" -o "$addYumAlias" = "N" ] ; then
    sudo cat ./bin/other/install-yum-aliases.sh | sudo tee -a /etc/bash.bashrc &>/dev/null
  fi

  echo -e "\n# AspieSoft Added Aliases - END\n" | sudo tee -a /etc/bash.bashrc &>/dev/null


  endLoading "$loading"
) &
runLoading "$loading"


# clean up
unset addYumAlias
unset loading
