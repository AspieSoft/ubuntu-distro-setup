#!/bin/bash

DIR="$1"

scanList=$(mktemp) && echo "" > $scanList

inotifywait -q -m -r -e close_write,moved_to --format '%w%f' $DIR | while read FILE
do
  if [ -s "$FILE" ] ; then

    isScanning="false"
    while read line ; do
      if [ "$line" = "$FILE" ] ; then
        isScanning="true"
        break
      fi
    done < $scanList

    if [ "$isScanning" = "true" ] ; then
      continue
    fi

    echo "$FILE" >> $scanList
    (
      fileName=$(echo $FILE | sed -e "s#^$DIR/##")
      clamscan -r --bell --move="/virusScan/quarantine" --exclude-dir="/virusScan/quarantine" $watchDir &>/dev/null
      sed "#^$FILE$#d" $scanList

      if [ -s "$FILE" ] ; then
        notify-send -i "$PWD/icon.png" -t 3 "Finished Scanning $fileName"
      fi
    ) &
  fi
done
