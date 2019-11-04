#!/bin/bash

password=$(cat .password)


ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "dc=jose,dc=labredes,dc=info" "(objectClass=posixAccount)" -w $password | grep uid: | cut -d" " -f2 > tmp.txt

count=1

while read line
do
list=$(echo $list $(echo "$line $count"))
count=$(expr $count + 1)
done < tmp.txt

echo $list




rm -rf tmp.txt
