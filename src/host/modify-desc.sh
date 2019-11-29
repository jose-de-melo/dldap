#!/bin/bash

password=$( cat .password )
host=$1

desc=$( dialog --stdout                         \
   --backtitle 'DLDAP - Alterar Máquina'      \
   --title "Alterar descrição da máquina: $host"                         \
   --inputbox '\n\nInsira a nova descrição: '  \
   13 50 )

if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

if [ -z "$desc" ];
then
        dialog --backtitle 'DLDAP - Alterar Máquina' --title 'Erro!' --msgbox 'O novo valor não pode estar vazio!' 6 40
        src/dldap-hosts.sh
        exit
fi

desc=$(echo $desc | sed 'y/áÁàÀãÃâÂéÉêÊíÍóÓõÕôÔúÚçÇ/aAaAaAaAeEeEiIoOoOoOuUcC/')

cat src/host/ldifs/modify.ldif | sed "s/<attr>/description/" | sed "s/<host>/$host/" | sed "4c\description: $desc" > $host.ldif

ldapmodify -x -D 'cn=admin,dc=jose,dc=labredes,dc=info' -H ldap://ldap1 -f $host.ldif -w $password >> logs/modify-hosts.log


echo "$(date "+%H:%M") - MODIFY DESCRIPTION FROM HOST $host TO $desc" >> logs/$(date "+%d%m%Y")-dldap.log

mv $host.ldif logs/ldifs

dialog                                            \
  --backtitle 'DLDAP - Alterar Máquina'                 \
   --title 'Sucesso!'                             \
   --msgbox "A descrição da máquina $host foi atualizada."  \
   6 40

src/dldap-hosts.sh
