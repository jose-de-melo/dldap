#!/bin/bash

##############################
## Obtendo o grupo passado como parâmetro
##############################
group=$1

##################
## Exibindo as opções para gerência de usuários de um grupo
##################
resposta=$(
      dialog --stdout               \
             --backtitle "DLDAP - Alterar Grupo"      \
             --title "Alterar Grupo: $group"  \
             --menu 'Selecione uma opção:' \
            0 0 0                   \
            1 'Adicionar usuário ao grupo'  \
            2 'Remover usuário do grupo'     \
            0 'Cancelar'                )


##############################
## Verificando se o usuário apertou ESC ou em Cancel
##############################
if [ $? -ne 0 ]; 
then
	src/dldap-groups.sh
	exit
fi

########################
## Direcionando o usuário de acordo a opção escolhida acima
########################
case "$resposta" in
         1) src/group/modify-groups-add-user.sh $group ;;
         2) src/group/modify-groups-remove-user.sh $group ;;
         0) src/group/modify.sh ;;
esac
