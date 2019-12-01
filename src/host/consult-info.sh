#!/bin/bash

## Obtendo as informações da base LDAP a ser gerenciada
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Obtendo o nome da máquina passado como parâmetro
cn=$1

## Obtendo a descrição da máquina
desc=$(ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "cn=$cn,ou=Maquinas,$base" "objectClass=nisNetGroup" -w $password | grep description: | cut -d" " -f2-)

## Obtendo as interfaces da máquina e armazenando em um arquivo temporário
ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "cn=$cn,ou=Maquinas,$base" "(objectClass=ipHost)" -w $password > tmp

## Tratando os dados das interfaces obtidas
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

## Removendo o arquivo temporário
rm -rf tmp

## Exibindo as informações da máquina
dialog --backtitle "DLDAP - Consultar Máquina"      \
   --title "Informações do Host : $cn"   \
   --msgbox "\nDESCRIÇÃO: $desc\n$txtIf" 10 70

## Voltando a tela de gerência de hosts
src/dldap-hosts.sh
