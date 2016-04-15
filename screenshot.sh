#!/bin/bash

screenshot() {
  img_file="$PWD/screenshot.png"

  open "bitbar://screenshot?pluginPath=$PWD/Plugins/$1&dst=${img_file}&margin=10"

  COUNTER=0
  while [ ! -f "${img_file}" ]
  do
    sleep 1
    let COUNTER+=1
    if [ $COUNTER -ge 10 ]; then
      break
    fi
  done

  response="$(curl -L -H "Authorization: Client-ID $IMGUR_API_KEY" -F "image=@\"${img_file}\"" https://api.imgur.com/3/image)"

  rm "${img_file}"

  # JSON parser
  # https://github.com/jomo/imgur-screenshot
  if egrep -q '"success":\s*true' <<<"${response}"; then
    img_id="$(egrep -o '"id":\s*"[^"]+"' <<<"${response}" | cut -d "\"" -f 4)"
    img_ext="$(egrep -o '"link":\s*"[^"]+"' <<<"${response}" | cut -d "\"" -f 4 | rev | cut -d "." -f 1 | rev)" # "link" itself has ugly '\/' escaping and no https!

    echo "https://i.imgur.com/${img_id}.${img_ext}"
  fi
}

defaults write com.apple.dock autohide -bool true; killall Dock
defaults write com.apple.finder CreateDesktop -bool false; killall Finder

curl -L https://github.com/matryer/bitbar/releases/download/v2.0.0-beta3/BitBar-v2.0.0-beta3.zip > BitBar.zip
unzip BitBar.zip

curl -L https://github.com/matryer/bitbar-plugins/archive/master.zip > bitbar-plugins-master.zip
unzip bitbar-plugins-master.zip

defaults write com.matryer.BitBar pluginsDirectory "$PWD/Plugins"

chmod -R +x bitbar-plugins-master

open BitBar.app

for f in $(find bitbar-plugins-master -name '*.*');
do
  if grep -q "<bitbar.image>" "$f"; then
  	echo "$f already has an image! Not taking a screenshot."
  else
  	echo "$f"
    screenshot "$f"
  fi
done

killall BitBar
dark-mode --mode Dark
open BitBar.app

for f in $(find bitbar-plugins-master -name '*.*');
do
  if grep -q "<bitbar.image>" "$f"; then
  	echo "Dark mode $f already has an image! Not taking a screenshot."
  else
  	echo "Dark mode $f"
    screenshot "$f"
  fi
done
