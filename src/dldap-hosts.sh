#!/bin/bash

################
## Exibindo o menu de gerenciamento de máquinas
################
op=$( dialog --cancel-label "Voltar" --backtitle 'DLDAP - Gerenciamento de Máquinas' \
        --stdout                 \
        --menu 'Selecione uma opção:'       \
        0 0 0                    \
        1 'Adicionar Máquina' \
        2 'Consultar Máquina' \
        3 'Alterar Máquina' \
        4 'Excluir Máquina' \
        0 'Voltar'  )

###############
## Verificando se o usuário apertou a tecla ESC ou em Voltar
###############
if [ $? -ne 0 ];then
        ./dldap.sh
        exit
fi

##############
## Direcionando o usuário de acordo com aopção escolhida
##############
case "$op" in
        1) src/host/add.sh ;;
        2) src/host/consult.sh ;;
        3) src/host/modify.sh ;;
        4) src/host/del.sh ;;
        0) ./dldap.sh ;;
esac
