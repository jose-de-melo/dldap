#!/bin/bash

password=$(cat .password)

hosts=$(ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "ou=Maquinas,dc=jose,dc=labredes,dc=info" "objectClass=nisNetGroup" -w $password | grep cn: | cut -d" " -f2)


LIST=()

for h in $(echo $hosts)
do
        DESC=''
        LIST+=( $h "$DESC" off)
done

host=$( dialog --stdout \
        --backtitle "DLDAP - Gerenciamento de Máquinas" \
        --title "Consultar Máquina" \
        --radiolist '' 0 40 0 \
        "${LIST[@]}" \
       )

if [ $? -ne 0 ]; then
	src/dldap-hosts.sh
	exit
fi

cn=$host

op=$( dialog --cancel-label "Voltar" --backtitle 'DLDAP - Gerenciamento de Máquinas' \
        --stdout                 \
        --menu 'Selecione uma opção:'       \
        0 0 0                    \
        1 "Consultar Informações : $cn" \
        2 "Consultar Interfaces : $cn" \
        0 'Voltar'  )

if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi


case "$op" in
        1) src/host/consult-info.sh $cn;;
        2) src/host/consult-ifs.sh $cn;;
        0) ./dldap-hosts.sh ;;
esac
