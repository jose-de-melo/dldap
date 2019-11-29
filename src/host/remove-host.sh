#!/bin/bash

password=$(cat .password)
host=$1

ifs=$( ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "cn=$host,ou=Maquinas,dc=jose,dc=labredes,dc=info" "(objectClass=ipHost)" -w $password | grep "dn: cn=" | cut -d" " -f2 | cut -d"," -f1 | cut -d"=" -f2 )

for int in $(echo $ifs)
do
	ldapdelete -x -D 'cn=admin,dc=jose,dc=labredes,dc=info' -H ldap://ldap1 "cn=$int,cn=$host,ou=Maquinas,dc=jose,dc=labredes,dc=info" -w $password >> /dev/null	
done

ldapdelete -x -D 'cn=admin,dc=jose,dc=labredes,dc=info' -H ldap://ldap1 "cn=$host,ou=Maquinas,dc=jose,dc=labredes,dc=info" -w $password >> /dev/null

echo "$(date "+%H:%M") - DELETE HOST $host" >> logs/$(date "+%d%m%Y")-dldap.log
