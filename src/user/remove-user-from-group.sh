#!/bin/bash

## Obtendo as informações da base
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Obtendo o usuário recebido como parâmetro
user=$1

## Montando o filtro para a pesquisa
filter="uniqueMember=uid=$user,ou=Usuarios,$base"

## Buscando todos os grupos nos quais o usuário é membro
groups=$(ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "$base" "(&(objectClass=posixGroup)($filter))" cn -w $password | grep cn: | cut -d" " -f2)

## Removendo o usuário de todos os grupos dos quais faz parte
for group in $groups
do
	src/group/add-or-del-user-group.sh delete $group $user
done
