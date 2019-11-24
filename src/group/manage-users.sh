#!/bin/bash

group=$1

resposta=$(
      dialog --stdout               \
             --backtitle "DLDAP - Alterar Grupo"      \
             --title "Alterar Grupo: $group"  \
             --menu 'Selecione uma opção:' \
            0 0 0                   \
            1 'Adicionar usuário ao grupo'  \
            2 'Remover usuário do grupo'     \
            0 'Cancelar'                )

if [ $? -ne 0 ]; 
then
	src/dldap-users.sh
	exit
fi

case "$resposta" in
         1) src/group/modify-groups-add-user.sh $group ;;
         2) src/group/modify-groups-remove-user.sh $group ;;
         0) src/group/modify.sh ;;
esac
