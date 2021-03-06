#!/bin/bash

#####################
## Exibindo o menu de Gerenciamento de Usuários
#####################
op=$( dialog --cancel-label "Voltar" --backtitle 'DLDAP - Gerenciamento de Usuários' \
        --stdout                 \
        --menu 'Selecione uma opção:'       \
        0 0 0                    \
        1 'Adicionar Usuário' \
        2 'Consultar Usuário' \
	3 'Alterar Usuário' \
        4 'Excluir Usuário' \
	0 'Voltar'  )

####################
## Verificando se o usuário apertou ESC ou na opção Voltar
####################
if [ $? -ne 0 ];then
	./dldap.sh
	exit
fi

####################
## Direcionando o usuário de acordo com a opção escolhida
####################
case "$op" in
        1) src/user/add-user.sh ;;
        2) src/user/consult.sh ;;
	3) src/user/modify-user.sh ;;
        4) src/user/del-user.sh ;;
        0) ./dldap.sh ;;
esac
