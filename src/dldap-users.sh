#!/bin/bash


op=$( dialog --backtitle 'DLDAP - Gerenciamento de Usuários' \
        --stdout                 \
        --menu 'Selecione uma opção:'       \
        0 0 0                    \
        1 'Consultar Usuário' \
        2 'Alterar Usuário' \
        3 'Excluir Usuário' \
	0 'Sair'  )

[ $? -ne 0 ] && exit


case "$op" in
        1) src/user/consult.sh ;;
        2) ./src/dldap-groups.sh ;;
        3) ./src/user/del-user.sh ;;
        0) exit 0;;
esac
