#!/bin/bash

#######################
## Script utilizado para remover acentos e transformar colocar o texto em letras minúsculas.
#######################


## Texto
str=$1

## Operação. Pode ser tolower, noaccent ou double (tolower + noaccent)
operation=$2

###############
## Executando a operação passada como parâmetro com a ajuda dos comandos echo, tr e sed.
###############

if [ "$operation" = "tolower" ]; then
	echo $1 | tr 'A-Z' 'a-z'
	exit
fi

if [ "$operation" = "noaccent" ]; then
	echo $1 | sed 'y/áÁàÀãÃâÂéÉêÊíÍóÓõÕôÔúÚçÇ/aAaAaAaAeEeEiIoOoOoOuUcC/'
	exit
fi

if [ "$operation" = "double" ]; then
	str=$(echo $str | tr 'A-Z' 'a-z')
	echo $str | sed 'y/áÁàÀãÃâÂéÉêÊíÍóÓõÕôÔúÚçÇ/aAaAaAaAeEeEiIoOoOoOuUcC/'
fi
