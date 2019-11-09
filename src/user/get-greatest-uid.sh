#!/bin/bash

password=$(cat .password)

ldapsearch -LLL -x -D 'cn=admin,dc=jose,dc=labredes,dc=info' -H ldap://ldap1 -b 'ou=Usuarios,dc=jose,dc=labredes,dc=info' '(objectClass=posixAccount)' uidNumber -w $password | grep uidNumber: | cut -d" " -f2 | sort -nr > tmp

uid=$(head -n 1 tmp)

echo $uid





rm -rf tmp


