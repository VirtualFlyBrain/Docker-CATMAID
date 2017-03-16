#!/bin/bash

server="tftp://$2/catmaid"

while IFS= read -r path; do
    [[ "$path" =~ ^\ *$ ]] && continue
    dir="$(dirname "$path")"
    printf "GET /catmaid/%s => /opt/VFB/%s\n" "$path" "$dir"
    ! [ -d "$dir" ] && mkdir -p "/opt/VFB/$dir"
    curl -o "$path" "$server/$path"
done < "$1"
