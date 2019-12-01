#!/bin/bash


## Obtendo as informações da base
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Listando e ordenando todos os uids já utilizados na base ldap e armazenando em um arquivo
## temporário
ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "ou=Usuarios,$base" '(objectClass=posixAccount)' uidNumber -w $password | grep uidNumber: | cut -d" " -f2 | sort -nr > tmp

## Obtendo o maior uid cadastrado
uid=$(head -n 1 tmp)

## Exibindo o maior uid obtido
echo $uid

## Removendo o arquivo temporário utilizado
rm -rf tmp
