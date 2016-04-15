#!/bin/bash

screenshot() {
  img_file="$PWD/screenshot.png"

  open "bitbar://screenshot?pluginPath=$PWD/Plugins/$1&dst=${img_file}&margin=10"

  while [ ! -f "${img_file}" ]
  do
    sleep 1
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

defaults write com.matryer.BitBar pluginsDirectory "$PWD/Plugins"

chmod +x Plugins/brew-updates.1h.sh

open BitBar.app

screenshot cycle_text_and_detail.sh
screenshot brew-updates.1h.sh

killall BitBar
dark-mode --mode Dark
open BitBar.app

screenshot cycle_text_and_detail.sh
screenshot brew-updates.1h.sh
