#!/bin/bash

## Obtendo as informações da base
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Obtendo o uid recebido como parâmetro
uid=$1

## Executando a adição
ldapadd -x -D "$userBase" -H ldap://ldap1 -f src/user/ldifs/$uid.ldif -w $password >> /dev/null

## Gerando o arquivo de log para a operação
echo "$(date "+%H:%M") - ADD USER $uid" >> logs/$(date "+%d%m%Y")-dldap.log
