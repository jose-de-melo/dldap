#!/bin/bash

password=$(cat .password)
host=$1
interface=$2
attr=$3
msg=$4


value=$(dialog --stdout                         \
   --backtitle 'DLDAP - Alterar Máquina'      \
   --title "Alterar $attr"                         \
   --inputbox "\n\n$msg"  \
   13 50 )


if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

if [ -z "$value" ];then
        dialog --backtitle 'DLDAP - Alterar Máquina' --title 'Erro!' --msgbox "Valor inválido para o atributo $attr!" 6 40
        src/dldap-hosts.sh
        exit
fi

value=$(src/adjust-text.sh "$value" noaccent)

cat src/host/ldifs/modify-if.ldif | sed "s/<interface>/$interface/" | sed "s/<host>/$host/" | sed "s/<attr>/$attr/" | sed "4c\\$attr: $value" > modify-$attr-$interface-$host.ldif

ldapmodify -x -D 'cn=admin,dc=jose,dc=labredes,dc=info' -H ldap://ldap1 -f modify-$attr-$interface-$host.ldif -w $password > /dev/null


echo "$(date "+%H:%M") - MODIFY $attr OF INTERFACE $interface FROM HOST $host" >> logs/$(date "+%d%m%Y")-dldap.log
mv modify-$attr-$interface-$host.ldif logs/ldif

dialog                                            \
  --backtitle 'DLDAP - Alterar Máquina'                 \
   --title 'Sucesso!'                             \
   --msgbox "A interface $interface da máquina $host foi atualizada!"  \
   6 40

src/dldap-hosts.sh
