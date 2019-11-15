#!/bin/bash

password=$(cat .password)

groups=$(ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "dc=jose,dc=labredes,dc=info" "(objectClass=posixGroup)" cn -w $password | grep cn: | cut -d" " -f2)



for line in $(echo $groups)
do
	echo $line
done

