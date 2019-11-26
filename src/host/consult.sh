#!/bin/bash

password=$(cat .password)

hostInfo=$(ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "ou=Maquinas,dc=jose,dc=labredes,dc=info" "objectClass=nisNetGroup" -w $password )

hosts=$(cat $hostInfo | grep cn: | cut -d" " -f2)


LIST=()

for host in $(echo $hosts)
do
        DESC=''
        LIST+=( $host "$DESC" off)
done

host=$( dialog --stdout \
        --backtitle "DLDAP - Gerenciamento de Máquinas" \
        --title "Consultar Máquina" \
        --separate-output \
        --checklist '' 0 40 0 \
        "${LIST[@]}" \
       )

if [ $? -ne 0 ]; then
	src/dldap-hosts.sh
	exit
fi

cn=$host

ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "cn=$cn,ou=Maquinas,dc=jose,dc=labredes,dc=info" "(objectClass=ipHost)" -w $password > tmp

ifs=$(cat tmp | grep cn: | cut -d" " -f2)

for interface in $ifs
do
	echo $interface
done




rm -rf tmp
