#!/bin/bash

password=$(cat .password)
group=$1



desc=$( dialog --stdout                         \
   --backtitle 'DLDAP - Alterar Grupo'      \
   --title "Alterar descrição do grupo: $group"                         \
   --inputbox '\n\nInsira a nova descrição: '  \
   13 50 )

if [ $? -ne 0 ];then
	src/dldap-groups.sh
	exit
fi

if [ -z "$desc" ];
then
        dialog --backtitle 'DLDAP - Alterar Grupo' --title 'Erro!' --msgbox 'O novo valor não pode ser vazio!' 6 40
        src/dldap-groups.sh
        exit
fi

desc=$(echo $desc | sed 'y/áÁàÀãÃâÂéÉêÊíÍóÓõÕôÔúÚçÇ/aAaAaAaAeEeEiIoOoOoOuUcC/')

cat src/group/ldifs/add-description.ldif | sed "s/<group>/$group/" | sed "4c\description: $desc" > $group.ldif


ldapmodify -x -D 'cn=admin,dc=jose,dc=labredes,dc=info' -H ldap://ldap1 -f $group.ldif -w $password >> logs/modify-groups.log

echo -e "MODIFY DESCRIPTION FROM GROUP $group TO $desc \n" >> logs/modify-groups.log

mv $group.ldif logs/ldifs


dialog                                            \
  --backtitle 'DLDAP - Alterar Grupo'                 \
   --title 'Sucesso!'                             \
   --msgbox "A descrição do grupo $group foi atualizada."  \
   6 40

src/dldap-groups.sh



