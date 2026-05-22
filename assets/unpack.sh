#!/bin/sh
directory=$(dirname $(readlink -f "$0"))
mkdir -p "$directory/1x/jokers"
magick "$directory/1x/joker.png" -crop 71x95 +repage +adjoin "$directory/1x/jokers/%02d.png"
