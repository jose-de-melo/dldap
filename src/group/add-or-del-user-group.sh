#!/bin/bash

password=$(cat .password)

operation=$1
group=$2
uid=$3

cat src/group/ldifs/add-user.ldif | sed "s/<operation>/$operation/"  | sed "s/<group>/$group/" | sed "s/<uid>/$uid/" >> $operation-$uid-$group.ldif

ldapmodify -x -D 'cn=admin,dc=jose,dc=labredes,dc=info' -H ldap://ldap1 -f $operation-$uid-$group.ldif -w $password >> logs/$operation-user-group.log


if [ $operation = "add" ];
then
	echo "$(date "+%H:%M") - ADD MEMBER $uid TO GROUP $group" >> logs/$(date "+%d%m%Y")-dldap.log
else
	echo "$(date "+%H:%M") - DELETE MEMBER $uid FROM GROUP $group" >> logs/$(date "+%d%m%Y")-dldap.log
fi

mv $operation-$uid-$group.ldif logs/ldifs/
