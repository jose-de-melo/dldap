#!/bin/bash

ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "dc=jose,dc=labredes,dc=info" "(objectClass=posixAccount)" -w zedocarmo | grep uid: | cut -d" " -f2 > tmp.txt

count=1

while read line
do
list=$(echo $list $(echo  "$count $line"))
count=$(expr $count + 1)
done < tmp.txt

echo $list




rm -rf tmp.txt
