#!/bin/bash


op=$( dialog --backtitle 'DLDAP - Gerenciamento de Usuários' \
        --stdout                 \
        --menu 'Selecione uma opção:'       \
        0 0 0                    \
        1 'Adicionar Usuário' \
        2 'Consultar Usuário' \
	3 'Alterar Usuário' \
        4 'Excluir Usuário' \
	0 'Sair'  )

[ $? -ne 0 ] && exit


case "$op" in
        1) src/user/add-user.sh ;;
        2) src/user/consult.sh ;;
	3) src/dldap-groups.sh ;;
        4) src/user/del-user.sh ;;
        0) exit 0;;
esac
