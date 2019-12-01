#!/bin/bash

## Obtendo as informações da base
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Obtendo os usuários da base LDAP
groups=$(ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "$base" "(objectClass=posixAccount)" cn -w $password | grep cn: | cut -d" " -f2)

## Montando os opções do radiolist
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

## Exibindo o radiolist com a lista de usuários
user=$( dialog --stdout --cancel-label "Voltar" \
        --backtitle 'DLDAP - Consultar Usuário'               \
        --radiolist 'Escolha um usuário para consultar:' \
        0 0 0                   \
	"${LIST[@]}" )

## Verificando se o usuário apertou ESC ou em Voltar
if [ $? -ne 0 ]; then
	src/dldap-users.sh
	exit
fi

## Exibindo as informações do usuário
src/user/show-user.sh $user
