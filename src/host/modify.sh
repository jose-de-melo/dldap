#!/bin/bash

## Obtendo os dados da base
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Obtendo os hosts cadastrados na base
hosts=$(ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "ou=Maquinas,$base" "objectClass=nisNetGroup" -w $password | grep cn: | cut -d" " -f2)

## Gerando a lista com os hosts cadastrados na base
LIST=()
DESC=''
for h in $(echo $hosts)
do
        LIST+=( $h "$DESC" off)
done

## Mostrando menu com os hosts cadastrados na base
host=$( dialog --stdout \
        --backtitle "DLDAP - Gerenciamento de Máquinas" \
        --title "Alterar Máquina" \
        --radiolist '' 0 40 0 \
        "${LIST[@]}" \
       )

## Verificando se o usuário apertou ESC ou em Cancel
if [ $? -ne 0 ]; then
        src/dldap-hosts.sh
        exit
fi

## Obtendo o host selecionado
cn=$host

## Exibindo menu com as opções de alteração disponíveis
op=$( dialog --cancel-label "Voltar" --backtitle 'DLDAP - Gerenciamento de Máquinas' \
        --stdout                 \
        --menu 'Selecione uma opção:'       \
        0 0 0                    \
        1 "Alterar Descrição : $cn" \
        2 "Alterar uma Interface : $cn" \
	3 "Adicionar uma Interface : $cn" \
	4 "Remover uma Interface : $cn" \
        0 'Voltar'  )

## Verificando se o usuário apertou ESC ou em Cancel
if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

## Direcionando o usuário de acordo com a opção desejada
case "$op" in
        1) src/host/modify-desc.sh $cn;;
        2) src/host/modify-if.sh $cn;;
	3) src/host/add-if.sh $cn;;
	4) src/host/remove-if.sh $cn;;
        0) ./dldap-hosts.sh ;;
esac
