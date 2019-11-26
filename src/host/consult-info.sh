#!/bin/bash

cn=$1
password=$(cat .password)

desc=$(ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "cn=$cn,ou=Maquinas,dc=jose,dc=labredes,dc=info" "objectClass=nisNetGroup" -w $password | grep description: | cut -d" " -f2-)

ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "cn=$cn,ou=Maquinas,dc=jose,dc=labredes,dc=info" "(objectClass=ipHost)" -w $password > tmp

ifs=$(cat tmp | grep "dn: cn=" | cut -d" " -f2 | cut -d"," -f1 | cut -d"=" -f2)


txtIf="INTERFACES: "
first=0
for interface in $ifs
do
	if [ $first -eq 0 ];then
		txtIf+="$interface"
		first=1
	else
		txtIf+=", $interface"
	fi 
done

dialog --backtitle "DLDAP - Consultar Máquina"      \
   --title "Informações da Host : $cn"   \
   --msgbox "\nDESCRIÇÃO: $desc\n$txtIf" 10 70

rm -rf tmp

src/dldap-hosts.sh

