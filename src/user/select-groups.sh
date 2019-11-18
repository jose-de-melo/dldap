#!/bin/bash
op=$1
user=$2
title=$3
backtitle=$4

addFilter="!(uniqueMember=uid=$user,ou=Usuarios,dc=jose,dc=labredes,dc=info)"
delFilter="uniqueMember=uid=$user,ou=Usuarios,dc=jose,dc=labredes,dc=info"
password=$(cat .password)


if [ $op = "add" ]; then
	filter=$addFilter
else
	filter=$delFilter
fi

groups=$(ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "dc=jose,dc=labredes,dc=info" "(&(objectClass=posixGroup)($filter))" cn -w $password | grep cn: | cut -d" " -f2)


LIST=()

for linha in $(echo $groups)
do
	DESC=''
	LIST+=( $linha "$DESC" off)
done

grupos=$( dialog --stdout \
	--backtitle "$backtitle" \
	--title "$title" \
        --separate-output \
        --checklist '' 0 40 0 \
	"${LIST[@]}" \
	)


[ $? -ne 0 ] && echo "null" && exit 


echo $grupos
