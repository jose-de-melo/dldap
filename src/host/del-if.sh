#!/bin/bash

password=$(cat .password)
host=$1
int=$2

ldapdelete -x -D 'cn=admin,dc=jose,dc=labredes,dc=info' -H ldap://ldap1 "cn=$int,cn=$host,ou=Maquinas,dc=jose,dc=labredes,dc=info" -w $password >> /dev/null

echo "$(date "+%H:%M") - DELETE INTERFACE $int FROM $host" >> logs/$(date "+%d%m%Y")-dldap.log
