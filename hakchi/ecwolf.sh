#!/bin/sh -e

self="$(readlink -f "$0")"
name="$(basename "$self" .sh)"
cdir="$(dirname "$self")"
code="$(basename "$cdir")"
config="/var/saves/$code/.config/$name/$name.cfg"

cd "$cdir/$name"
[ -x "$name" ] || chmod +x "$name"
mkdir -p "/var/saves/$code/.config/$name"
[ -f "$config" ] || cp "$name.cfg" "/var/saves/$code/.config/$name/"
if [ "$(cat /dev/clovercon1)" = 0800 ]; then
  decodepng "$cdir/$name/ecwolf.png" > /dev/fb0
  ecwolfgame=-1
  for i in gamemaps.wl6 gamemaps.sdm gamemaps.sod gamemaps.wl1 gamemaps.n3d gamemaps.sd3 gamemaps.sd2; do
    gamefile="$(ls | grep -i "$i" | tr [:lower:] [:upper:])"
    game_ext="${gamefile#*.}"
    if [ ! -z "$gamefile" ]; then
      ecwolfgame="$((ecwolfgame + 1))"
      eval "$(echo "$game_ext")"="$ecwolfgame"
    fi
  done
  until button_id="$(cat /dev/clovercon1 | grep "0004\|0008\|0001\|0100\|0200\|0002\|0400\|8000\|4000")"; do
    usleep 50000
  done
  if [ "$button_id" = 0001 ]; then
    [ ! -z "$SOD" ] && sed -i 's/DefaultIWad = [0-9];/DefaultIWad = '"$SOD"';/' "$config"
    [ -z "$SOD" ] && exit 1
  fi
  if [ "$button_id" = 0004 ]; then
    [ ! -z "$SD2" ] && sed -i 's/DefaultIWad = [0-9];/DefaultIWad = '"$SD2"';/' "$config"
    [ -z "$SD2" ] && exit 1
  fi
  if [ "$button_id" = 0008 ]; then
    [ ! -z "$SD3" ] && sed -i 's/DefaultIWad = [0-9];/DefaultIWad = '"$SD3"';/' "$config"
	[ -z "$SD3" ] && exit 1
  fi
  if [ "$button_id" = 0100 ]; then
    [ ! -z "$WL6" ] && sed -i 's/DefaultIWad = [0-9];/DefaultIWad = '"$WL6"';/' "$config"
	[ -z "$WL6" ] && exit 1
  fi
  if [ "$button_id" = 0200 ]; then
    [ ! -z "$N3D" ] && sed -i 's/DefaultIWad = [0-9];/DefaultIWad = '"$N3D"';/' "$config"
	[ -z "$N3D" ] && exit 1
  fi
  if [ "$button_id" = 4000 ]; then
    [ ! -z "$WL1" ] && sed -i 's/DefaultIWad = [0-9];/DefaultIWad = '"$WL1"';/' "$config"
	[ -z "$WL1" ] && exit 1
  fi
  if [ "$button_id" = 8000 ]; then
    [ ! -z "$SDM" ] && sed -i 's/DefaultIWad = [0-9];/DefaultIWad = '"$SDM"';/' "$config"
	[ -z "$SDM" ] && exit 1
  fi
  [ "$button_id" = 0002 ] && rm "$config" && exit 1
  [ "$button_id" = 0400 ] && exit 1
fi
sed -i 's/ShowIWadPicker = 1;/ShowIWadPicker = 0;/' "$config"
HOME="/var/saves/$code" exec "./$name"
