#!/bin/bash

password=$(cat .password)


ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "dc=jose,dc=labredes,dc=info" "(objectClass=posixAccount)" -w $password | grep uid: | cut -d" " -f2 > tmp.txt

while read line
do
gecos=$(ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "dc=jose,dc=labredes,dc=info" "(&(objectClass=posixAccount)(uid=$line))" gecos -w $password | grep gecos: | awk -F": " '{print $2}')
list=$(echo $list $(echo -e "$line '$gecos' off\n"))
done < tmp.txt

echo $list




rm -rf tmp.txt
