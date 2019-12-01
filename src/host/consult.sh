#!/bin/bash

## Obtendo as informações da base
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Obtendo os hosts cadastrados na base LDAP
hosts=$(ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "ou=Maquinas,$base" "objectClass=nisNetGroup" -w $password | grep cn: | cut -d" " -f2)

## Gerando a lista de opções para o radiolist a seguir
LIST=()
DESC=''
for h in $(echo $hosts)
do
        LIST+=( $h "$DESC" off)
done

## Exibindo o radiolist de hosts cadastrados
host=$( dialog --stdout \
        --backtitle "DLDAP - Gerenciamento de Máquinas" \
        --title "Consultar Máquina" \
        --radiolist '' 0 40 0 \
        "${LIST[@]}" \
       )

## Verificando se o usuário apertou ESC ou em Cancel
if [ $? -ne 0 ]; then
	src/dldap-hosts.sh
	exit
fi

## Obtendo a cn do host selecionado
cn=$host

## Exibindo o menu com as opções de consulta
op=$( dialog --cancel-label "Voltar" --backtitle 'DLDAP - Gerenciamento de Máquinas' \
        --stdout                 \
        --menu 'Selecione uma opção:'       \
        0 0 0                    \
        1 "Consultar Informações : $cn" \
        2 "Consultar Interfaces : $cn" \
        0 'Voltar'  )

## Verificando se o usuário apertou ESC ou em Cancel
if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

## Direcionando o usuário de acordo com a opção escolhida
case "$op" in
        1) src/host/consult-info.sh $cn;;
        2) src/host/consult-ifs.sh $cn;;
        0) ./dldap-hosts.sh ;;
esac
