#!/bin/bash

str=$1
operation=$2

if [ "$operation" = "tolower" ]; then
	echo $1 | tr 'A-Z' 'a-z'
fi

if [ "$operation" = "noaccent" ]; then
	echo $1 | sed 'y/áÁàÀãÃâÂéÉêÊíÍóÓõÕôÔúÚçÇ/aAaAaAaAeEeEiIoOoOoOuUcC/'
fi

if [ "$operation" = "double" ]; then
	str=$(echo $str | tr 'A-Z' 'a-z')
	echo $str | sed 'y/áÁàÀãÃâÂéÉêÊíÍóÓõÕôÔúÚçÇ/aAaAaAaAeEeEiIoOoOoOuUcC/'
fi
