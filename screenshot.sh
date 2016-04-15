#!/bin/bash

screenshot() {
  img_file="$PWD/screenshot.png"

  open "bitbar://screenshot?pluginPath=$PWD/$1&dst=${img_file}&margin=10"

  COUNTER=0
  while [ ! -f "${img_file}" ]
  do
    sleep 1
    let COUNTER+=1
    if [ $COUNTER -ge 60 ]; then
      echo " timed out."
      killall BitBar
      return
    fi
  done

  response="$(curl -sSL -H "Authorization: Client-ID $IMGUR_API_KEY" -F "image=@\"${img_file}\"" https://api.imgur.com/3/image)"

  rm "${img_file}"

  # JSON parser
  # https://github.com/jomo/imgur-screenshot
  if egrep -q '"success":\s*true' <<<"${response}"; then
    img_id="$(egrep -o '"id":\s*"[^"]+"' <<<"${response}" | cut -d "\"" -f 4)"
    img_ext="$(egrep -o '"link":\s*"[^"]+"' <<<"${response}" | cut -d "\"" -f 4 | rev | cut -d "." -f 1 | rev)" # "link" itself has ugly '\/' escaping and no https!

    echo ": https://i.imgur.com/${img_id}.${img_ext}"
  fi
}

defaults write com.apple.dock autohide -bool true; killall Dock
defaults write com.apple.finder CreateDesktop -bool false; killall Finder

curl -sSL https://github.com/matryer/bitbar/releases/download/v2.0.0-beta3/BitBar-v2.0.0-beta3.zip > BitBar.zip
unzip -q BitBar.zip

curl -sSL https://github.com/matryer/bitbar-plugins/archive/master.zip > bitbar-plugins-master.zip
unzip -q bitbar-plugins-master.zip

defaults write com.matryer.BitBar pluginsDirectory "$PWD/Plugins"

chmod -R +x bitbar-plugins-master

for f in $(find bitbar-plugins-master -name '*.*');
do
  if [ -f "$f" ]; then
    if [[ "$(basename "$f")" = "."* ]]; then
      continue
    fi
    if [ "$(basename "$f")" = "README.md" ]; then
      continue
    fi

    if grep -q "<bitbar.image>" "$f"; then
  	  #echo "$f: already has an image! Not taking a screenshot."
  	  true
    else
      if pgrep BitBar > /dev/null; then
  	    # BitBar is already running.
  	    true
  	  else
  	    echo "Launching BitBar..."
  	    open BitBar.app
  	  fi

  	  echo -n "$f"
      screenshot "$f"
    fi
  fi
done

killall BitBar
dark-mode --mode Dark
dark-mode --mode Dark

for f in $(find bitbar-plugins-master -name '*.*');
do
  if [ -f "$f" ]; then
    if [[ "$(basename "$f")" = "."* ]]; then
      continue
    fi
    if [ "$(basename "$f")" = "README.md" ]; then
      continue
    fi
    
    if grep -q "<bitbar.image>" "$f"; then
  	  #echo "Dark mode $f already has an image! Not taking a screenshot."
  	  true
    else
      if pgrep BitBar > /dev/null; then
  	    # BitBar is already running.
  	    true
  	  else
  	    echo "Launching BitBar..."
  	    open BitBar.app
  	  fi
  	  
  	  echo -n "$f (dark mode)"
      screenshot "$f"
    fi
  fi
done
