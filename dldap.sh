#!/bin/bash

dialog --backtitle "DLDAP" \
--title "Bem-vindo!" \
--msgbox 'Para prosseguir, aperte ENTER ou Ctrl+C para sair.' 10 30

resposta=$(
      dialog --backtitle "DLDAP" --stdout               \
             --title 'Menu'  \
             --menu 'Escolha uma opção:' \
            0 0 0                   \
            1 'Gerenciamento de Usuários' \
            2 'Gerenciamento de Grupos'  \
            3 'Gerenciamento de Máquinas'     \
            0 'Sair'                )

	

[ $? -ne 0 ] && exit


case "$resposta" in
	1) ./src/dldap-users.sh ;;
	2) ./src/dldap-groups.sh ;;
	3) ./src/dlap-hosts.sh ;;
	0) exit ;;
esac


