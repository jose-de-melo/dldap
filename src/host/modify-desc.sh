#!/bin/bash

## Obtendo os dados da base LDAP
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Obtendo o nome da máquina passada como parâmetro
host=$1

## Obtendo a nova descrição da máquina
desc=$( dialog --stdout                         \
   --backtitle 'DLDAP - Alterar Máquina'      \
   --title "Alterar descrição da máquina: $host"                         \
   --inputbox '\n\nInsira a nova descrição: '  \
   13 50 )

## Verificando se o usuário não apertou ESC ou em Cancel
if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

## Verificando se o usuário não deixou o campo em branco
if [ -z "$desc" ];
then
        dialog --backtitle 'DLDAP - Alterar Máquina' --title 'Erro!' --msgbox 'O novo valor não pode estar vazio!' 6 40
        src/dldap-hosts.sh
        exit
fi

## Removendo acentos e caracteres especiais
desc=$(src/adjust-text.sh "$desc" noaccent)

## Montando o arquivo ldif para a alteração
cat src/host/ldifs/modify.ldif | sed "s/<base>/$base/" | sed "s/<attr>/description/" | sed "s/<host>/$host/" | sed "4c\description: $desc" > $host.ldif

## Executando a operação
ldapmodify -x -D "$userBase" -H ldap://ldap1 -f $host.ldif -w $password > /dev/null

## Gerando log para a operação realizada
echo "$(date "+%H:%M") - MODIFY DESCRIPTION FROM HOST $host TO $desc" >> logs/$(date "+%d%m%Y")-dldap.log

## Movendo o arquivo ldif gerado para o diretório de logs
mv $host.ldif logs/ldifs

## Informando ao usuário que a operação foi realizada
dialog                                            \
  --backtitle 'DLDAP - Alterar Máquina'                 \
   --title 'Sucesso!'                             \
   --msgbox "A descrição da máquina $host foi atualizada."  \
   6 40

## Retornando a tela de gerência de máquinas
src/dldap-hosts.sh
