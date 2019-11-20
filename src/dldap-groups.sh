#!/bin/bash


op=$( dialog --backtitle 'DLDAP - Gerenciamento de Usuários' \
        --stdout                 \
        --menu 'Selecione uma opção:'       \
        0 0 0                    \
        1 'Adicionar Grupo' \
        2 'Consultar Grupo' \
        3 'Alterar Grupo' \
        4 'Excluir Grupo' \
        0 'Voltar'  )

[ $? -ne 0 ] && exit && ./dldap.sh


case "$op" in
        1) src/group/add.sh ;;
        2) src/group/consult.sh ;;
        3) src/group/modify.sh ;;
        4) src/group/del.sh ;;
        0) ./dldap.sh ;;
esac


