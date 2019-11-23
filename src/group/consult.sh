#!/bin/bash

password=$(cat .password)


groups=$(ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "dc=jose,dc=labredes,dc=info" "(objectClass=posixGroup)" cn -w $password | grep cn: | cut -d" " -f2)


LIST=()

first=true
DESC=''
for linha in $(echo $groups)
do
	if [ $first ];then
       		LIST+=( $linha "$DESC" on)
	else
		LIST+=( $linha "$DESC" off)
	fi
done

group=$( dialog --stdout \
        --backtitle "DLDAP - Consultar Grupo" \
        --title "Consultar Grupo" \
        --radiolist 'Selecione um grupo:' 0 40 0 \
        "${LIST[@]}" \
        )


[ $? -ne 0 ] && src/dldap-groups.sh && exit

ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "dc=jose,dc=labredes,dc=info" "(&(objectClass=posixGroup)(cn=$group))" -w $password > tmp

description=$( cat tmp | grep "description:" | cut -d" " -f2-)
members=$(cat tmp | grep "uniqueMember:" | cut -d":" -f2 | cut -d"," -f1 | cut -d"=" -f2)

strMember=''
first=true
for member in $members
do
	if [ "$first" == "true" ];
	then
		strMember+=$(echo "$member")
		first=false
	else
		strMember=$(echo "$member, $strMember")
	fi
done


dialog --backtitle "DLDAP - Consultar Grupo: $group"      \
   --title 'Dados do Grupo'   \
   --msgbox "\nNome (cn): $group\nDescrição: $description\nMembros: $strMember" 10 60





src/dldap-groups.sh
rm -rf tmp
