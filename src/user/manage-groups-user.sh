#!/bin/bash

user=$1

resposta=$(
      dialog --stdout               \
             --backtitle "DLDAP - Alterar Usuário"      \
             --title "Alterar Usuário: $user"  \
             --menu 'Selecione uma opção:' \
            0 0 0                   \
            1 'Adicionar o usuário a um grupo'  \
            2 'Remover o usuário do grupo'     \
            0 'Cancelar'                )

[ $? -ne 0 ] && src/dldap-users.sh && exit


case "$resposta" in
         1) src/user/modify-groups-add-user.sh $user ;;
         2) src/user/modify-groups-remove-user.sh $user ;;
         0) src/user/modify-user.sh ;;
esac
