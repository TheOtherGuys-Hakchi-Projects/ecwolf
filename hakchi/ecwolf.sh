#!/bin/sh -e

self="$(readlink -f "$0")"
name="$(basename "$self" .sh)"
cdir="$(dirname "$self")"
code="$(basename "$cdir")"
config="/var/saves/$code/.config/$name/$name.cfg"
HOME="/var/saves/$code"

cd "$cdir/$name"
[ -x "$name" ] || chmod +x "$name"
mkdir -p "/var/saves/$code/.config/$name"
[ -f "$HOME/save.sram" ] || touch "$HOME/save.sram"
[ -f "$config" ] || cp "$name.cfg" "/var/saves/$code/.config/$name/"
if [ "$(cat /dev/clovercon1)" = 0800 ]; then
  decodepng "$cdir/$name/ecwolf.png" > /dev/fb0
  until button_id="$(cat /dev/clovercon1 | grep "0004\|0008\|0001\|0100\|0200\|0002\|0400\|8000\|4000")"; do
    usleep 50000
  done
  [ "$button_id" = 0001 ] && gamefile="$(ls | grep -i gamemaps.sod)"
  [ "$button_id" = 0004 ] && gamefile="$(ls | grep -i gamemaps.sd2)"
  [ "$button_id" = 0008 ] && gamefile="$(ls | grep -i gamemaps.sd3)"
  [ "$button_id" = 0100 ] && gamefile="$(ls | grep -i gamemaps.wl6)"
  [ "$button_id" = 0200 ] && gamefile="$(ls | grep -i gamemaps.n3d)"
  [ "$button_id" = 4000 ] && gamefile="$(ls | grep -i gamemaps.wl1)"
  [ "$button_id" = 8000 ] && gamefile="$(ls | grep -i gamemaps.sdm)"
  [ "$button_id" = 0002 ] && rm "$config" && exit 1
  [ "$button_id" = 0400 ] && exit 1
  if [ ! -z "$gamefile" ]; then
    exec "./$name" --data "${gamefile#*.}"
  else
    exit 1
  fi
else
  sed -i 's/ShowIWadPicker = 1;/ShowIWadPicker = 0;/' "$config"
  exec "./$name"
fi
