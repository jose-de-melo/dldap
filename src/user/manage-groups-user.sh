#!/bin/bash

## Obtendo a nome do usuário passado como parâmetro
user=$1

## Exibindo menu com as opções para gerência de grupos de um usuário
resposta=$(
      dialog --stdout               \
             --backtitle "DLDAP - Alterar Usuário"      \
             --title "Alterar Usuário: $user"  \
             --menu 'Selecione uma opção:' \
            0 0 0                   \
            1 'Adicionar o usuário a um grupo'  \
            2 'Remover o usuário do grupo'     \
            0 'Cancelar'                )

## Verificando se o usuário apertou ESC ou em Cancel
if [ $? -ne 0 ];then
	src/dldap-users.sh
	exit
fi

## Direcionando o usuário de acordo com a opção escolhida
case "$resposta" in
         1) src/user/modify-groups-add-user.sh $user ;;
         2) src/user/modify-groups-remove-user.sh $user ;;
         0) src/user/modify-user.sh ;;
esac
