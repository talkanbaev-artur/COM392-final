#/bin/usr/bash

temp=$1
temp=$(printf "%s" "$temp" | sed --expression='s/bin/src/g')
temp=$(printf "%s" "$temp" | sed --expression='s/\.o/.cu/g')
echo $temp