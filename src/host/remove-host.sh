#!/bin/bash

## Obtendo os dados da base LDAP
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Obtendo o host a ser removido
host=$1

## Verificando se o host possui interfaces cadastrada
ifs=$( ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "cn=$host,ou=Maquinas,$base" "(objectClass=ipHost)" -w $password | grep "dn: cn=" | cut -d" " -f2 | cut -d"," -f1 | cut -d"=" -f2 )

## Removendo as interfaces do host, caso tenha alguma cadastrada
for int in $(echo $ifs)
do
	## Executando a deleção de uma interface da host
	ldapdelete -x -D "$userBase" -H ldap://ldap1 "cn=$int,cn=$host,ou=Maquinas,$base" -w $password > /dev/null	
	## Gerando log para a deleção
	echo "$(date "+%H:%M") - DELETE INTERFACE $int FROM HOST $host" >> logs/$(date "+%d%m%Y")-dldap.log
done

## Removendo o host
ldapdelete -x -D "$userBase" -H ldap://ldap1 "cn=$host,ou=Maquinas,$base" -w $password >> /dev/null

## Gerando log para a operação realizada
echo "$(date "+%H:%M") - DELETE HOST $host" >> logs/$(date "+%d%m%Y")-dldap.log
