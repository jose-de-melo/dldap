#!/bin/bash

resposta=$(
      dialog --cancel-label "Sair" --backtitle "DLDAP" --stdout               \
             --title 'Menu'  \
             --menu 'Escolha uma opção:' \
            0 0 0                   \
            1 'Gerenciamento de Usuários' \
            2 'Gerenciamento de Grupos'  \
            3 'Gerenciamento de Máquinas'     \
	    4 'Sobre o DLDAP'			\
            0 'Sair'                )

	

[ $? -ne 0 ] && exit


case "$resposta" in
	1) ./src/dldap-users.sh ;;
	2) ./src/dldap-groups.sh ;;
	3) ./src/dldap-hosts.sh ;;
	4) src/about-dldap.sh ;;
	0) exit ;;
esac


