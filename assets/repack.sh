#!/bin/sh
directory=$(dirname $(readlink -f "$0"))
mkdir -p "$directory/1x/jokers"

for i in $(seq 0 $(cd "$directory/1x/jokers/" && find *.png | tail -n +2 | wc -l)); do 
    files="$files $directory/1x/jokers/$i.png";
done

magick montage -background '#00000000' $files -geometry +0+0 "$directory/1x/joker.png"
"$directory/upscale.sh"
