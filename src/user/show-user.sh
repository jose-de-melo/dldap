#!/bin/bash

user=$1

ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "dc=jose,dc=labredes,dc=info" "(uid=$user)" -w zedocarmo > tmp

home=$(cat tmp | grep homeDirectory: | cut -d" " -f2)
shell=$(cat tmp | grep loginShell: | cut -d" " -f2)
gecos=$(cat tmp | grep gecos: | awk -F": " '{print $2}')

dialog --backtitle "DLDAP - Consultar usuário: $user"      \
   --title 'Dados do Usuário'   \
   --msgbox "
	Username: $user
	Gecos: $gecos
	Home: $home
	Shell: $shell" 10 40


rm -rf tmp

src/dldap-users.sh


