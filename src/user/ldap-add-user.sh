#!/bin/bash

password=$(cat .password)
uid=$1

ldapadd -x -D 'cn=admin,dc=jose,dc=labredes,dc=info' -H ldap://ldap1 -f src/user/ldifs/$uid.ldif -w $password >> /dev/null

echo "$(date "+%H:%M") - ADD USER $uid" >> logs/$(date "+%d%m%Y")-dldap.log
