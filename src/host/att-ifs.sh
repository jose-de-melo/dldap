#!/bin/bash

## Obtendo os dados da base LDAP a ser gerenciada
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Otendo os dados passados como parâmetro 
host=$1
interface=$2
attr=$3
msg=$4

## Lendo o valor para a informação a ser alterada
value=$(dialog --stdout                         \
   --backtitle 'DLDAP - Alterar Máquina'      \
   --title "Alterar $attr"                         \
   --inputbox "\n\n$msg"  \
   13 50 )

## Verificando se o usuário não apertou ESC ou em Cancel
if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

## Verificando se o usuário deixou o campo em branco
if [ -z "$value" ];then
        dialog --backtitle 'DLDAP - Alterar Máquina' --title 'Erro!' --msgbox "Valor inválido para o atributo $attr!" 6 40
        src/dldap-hosts.sh
        exit
fi

## Ajustando o valor lido 
value=$(src/adjust-text.sh "$value" noaccent)

## Montando o arquivo ldif
cat src/host/ldifs/modify-if.ldif | sed "s/<base>/$base/" | sed "s/<interface>/$interface/" | sed "s/<host>/$host/" | sed "s/<attr>/$attr/" | sed "4c\\$attr: $value" > modify-$attr-$interface-$host.ldif

## Executando a operação 
ldapmodify -x -D "$userBase" -H ldap://ldap1 -f modify-$attr-$interface-$host.ldif -w $password > /dev/null

## Gerando log para a operação e movendo o arquivo ldif gerado
echo "$(date "+%H:%M") - MODIFY $attr OF INTERFACE $interface FROM HOST $host" >> logs/$(date "+%d%m%Y")-dldap.log
mv modify-$attr-$interface-$host.ldif logs/ldif

## Informando que a operação foi realizada
dialog                                            \
  --backtitle 'DLDAP - Alterar Máquina'                 \
   --title 'Sucesso!'                             \
   --msgbox "A interface $interface da máquina $host foi atualizada!"  \
   6 40

## Retornando a tela de gerência de hosts
src/dldap-hosts.sh
