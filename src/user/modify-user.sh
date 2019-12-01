#!/bin/bash

## Obtendo as informações da base
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Obtendo todos os usuários cadastrados na base
output=$( ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "$base" "(objectClass=posixAccount)" -w $password | grep uid: | cut -d" " -f2 )

## Gerando a lista de usuários para o radiolist seguinte
LIST=()
count=0
for linha in $(echo $output)
do	
        DESC=''
	if [ $count -eq 0 ];
	then
        	LIST+=( $linha "$DESC" on)
		count=1
	else
		LIST+=( $linha "$DESC" off)
	fi
done

## Exibindo os usuários cadastrados na base
user=$( dialog --stdout \
        --backtitle "DLDAP - Alterar Usuário" \
        --title "Selecionar Usuário" \
        --radiolist '' 0 40 0 \
        "${LIST[@]}" \
)

## Verificando se o usuário apertou ESC ou em Cancel
if [ $? -ne 0 ]; then
	src/dldap-users.sh
	exit
fi

## Exibindo menu com as opções de alteração de um usuário
resposta=$(
      dialog --stdout               \
	     --backtitle "DLDAP - Alterar Usuário"	\
             --title "Alterar Usuário: $user"  \
             --menu 'Escolha um atributo para editar:' \
            0 0 0                   \
            1 'Alterar Gecos'  \
            2 'Alterar Senha'     \
            3 'Gerenciar Grupos'        \
            0 'Cancelar'                )

## Verificando se o usuário apertou ESC ou em Cancel
if [ $? -ne 0 ]; then
	src/dldap-users.sh
	exit
fi

## Direcionando o usuário de acordo com a opção escolhida 
case "$resposta" in
         1) src/user/modify-gecos-user.sh $user ;;
         2) src/user/modify-password-user.sh $user ;;
         3) src/user/manage-groups-user.sh $user ;;
         0) src/dldap-users.sh ;;
esac
