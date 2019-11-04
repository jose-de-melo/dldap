#!/bin/bash

user=$1

ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "dc=jose,dc=labredes,dc=info" "(uid=$user)" -w zedocarmo > tmp

home=$(cat tmp | grep homeDirectory: | cut -d" " -f2)
shell=$(cat tmp | grep loginShell: | cut -d" " -f2)
gecos=$(cat tmp | grep gecos: | cut -d" " -f2)
rm -rf tmp



