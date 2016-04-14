#!/bin/bash

curl -L https://github.com/matryer/bitbar/releases/download/v2.0.0-beta2/BitBar-v2.0.0-beta2.zip > BitBar.zip
unzip BitBar.zip

xattr -d com.apple.quarantine BitBar.app
open BitBar.app
img_file="$PWD/screenshot.png"
open "bitbar://screenshot?pluginPath=$PWD/cycle_text_and_detail.sh&dst=${img_file}&margin=10"

while [ ! -f "${img_file}" ]
do
  sleep 1
done 

response="$(curl -L -H "Authorization: Client-ID $IMGUR_API_KEY" -F "image=@\"${img_file}\"" https://api.imgur.com/3/image)"

# JSON parser
# https://github.com/jomo/imgur-screenshot
if egrep -q '"success":\s*true' <<<"${response}"; then
  img_id="$(egrep -o '"id":\s*"[^"]+"' <<<"${response}" | cut -d "\"" -f 4)"
  img_ext="$(egrep -o '"link":\s*"[^"]+"' <<<"${response}" | cut -d "\"" -f 4 | rev | cut -d "." -f 1 | rev)" # "link" itself has ugly '\/' escaping and no https!

  echo "https://i.imgur.com/${img_id}.${img_ext}"
fi
