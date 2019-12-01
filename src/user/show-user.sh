#!/bin/bash

## Obtendo as informações da base
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Obtendo o usuário passado como parâmetro
user=$1

## Buscando as informações do usuário
ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "$base" "(uid=$user)" -w $password > tmp

## Separando as informações obtidas e armazenadas no arquivo temporário
home=$(cat tmp | grep homeDirectory: | cut -d" " -f2)
shell=$(cat tmp | grep loginShell: | cut -d" " -f2)
gecos=$(cat tmp | grep gecos: | awk -F": " '{print $2}')

## Exibindo as informações do usuário 
dialog --backtitle "DLDAP - Consultar usuário: $user"      \
   --title 'Dados do Usuário'   \
   --msgbox "
	Username: $user
	Gecos: $gecos
	Home: $home
	Shell: $shell" 10 40

## Removendo o arquivo temporário
rm -rf tmp

## Voltando a tela de gerência de usuários
src/dldap-users.sh
