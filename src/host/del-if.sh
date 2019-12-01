#!/bin/bash

## Obtendo os dados da base LDAP
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Obtendo o host e a interface a ser removida
host=$1
int=$2

## Executando a deleção
ldapdelete -x -D "$userBase" -H ldap://ldap1 "cn=$int,cn=$host,ou=Maquinas,$base" -w $password > /dev/null

## Gerando log para a operação realizada
echo "$(date "+%H:%M") - DELETE INTERFACE $int FROM $host" >> logs/$(date "+%d%m%Y")-dldap.log
