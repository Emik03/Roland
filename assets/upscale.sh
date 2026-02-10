#!/bin/sh
directory=$(dirname $(readlink -f "$0"))

for file in "$directory"/1x/*.png; do
    filename=$(basename "$file")
    output_file="$directory/2x/${filename}"
    magick "$file" -filter point -resize 200% "$output_file"
done
