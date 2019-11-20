#!/bin/bash

password=$(cat .password)



gids=$(ldapsearch -LLL -x -D 'cn=admin,dc=jose,dc=labredes,dc=info' -H ldap://ldap1 -b 'ou=Grupos,dc=jose,dc=labredes,dc=info' '(objectClass=posixGroup)' gidNumber -w $password | grep gidNumber: | cut -d" " -f2)

base_gid=2000

for gid in $gids
do
	if [ gid -ne 10000 ]; then
		if [ gid -ne base_gid ]; then
			base_gid=gid
		fi
	fi
done


