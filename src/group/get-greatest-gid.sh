#!/bin/bash

############################################
## Script utilizado para gerar novos GIDs  #
############################################

#####################################
## Obtendo as informações da base
#####################################
base=$(./getconfig.sh base)
user=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

######################################
## Buscando todos os GIDs já utilizados
######################################
gids=$(ldapsearch -LLL -x -D "$user" -H ldap://ldap1 -b "ou=Grupos,$base" '(objectClass=posixGroup)' gidNumber -w $password | grep gidNumber: | cut -d" " -f2)

#####################################
## Gerando o próximo GID disponível, que será maior que 2000 e menor que 10000
#####################################
base_gid="2000"
for gid in $gids
do
	if [ $gid -le 10000 ]; then
		if [ $gid -gt $base_gid ]; then
			base_gid=$gid
		fi
	fi
done

#########################
## Exibindo o GID gerado
#########################
echo $base_gid
