#!/bin/bash

password=$(cat .password)

operation=$1
group=$2
uid=$3

cat src/group/ldifs/add-user.ldif | sed "s/<operation>/$operation/"  |sed "s/<group>/$group/" | sed "s/<uid>/$uid/" >> $operation-$uid-$group.ldif

ldapmodify -x -D 'cn=admin,dc=jose,dc=labredes,dc=info' -H ldap://ldap1 -f $operation-$uid-$group.ldif -w $password >> logs/$operation-user-group.log


if [ $operation = "add" ];
then
	echo -e "ADD MEMBER $uid TO GROUP $group\n" >> logs/$operation-user-group.log
else
	echo -e "DELETE MEMBER $uid FROM GROUP $group\n" >> logs/$operation-user-group.log
fi

mv $operation-$uid-$group.ldif logs/ldifs/
