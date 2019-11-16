#!/bin/bash

password=$(cat .password)
user=$1
filter="uniqueMember=uid=$user,ou=Usuarios,dc=jose,dc=labredes,dc=info"



groups=$(ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "dc=jose,dc=labredes,dc=info" "(&(objectClass=posixGroup)($filter))" cn -w $password | grep cn: | cut -d" " -f2)

for group in $groups
do
	src/group/add-or-del-user-group.sh delete $group $user
done
