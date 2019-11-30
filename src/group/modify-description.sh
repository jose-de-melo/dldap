#!/bin/bash

####################################
## Obtendo os dados da base LDAP
####################################
user=$(./getconfig.sh user)
base=$(./getconfig.sh base)
password=$(./getconfig.sh userPassword)

#################################
## Obtendo o grupo passado como parâmetro
#################################
group=$1

#####################################
## Lendo a nova descrição do grupo
#####################################
desc=$( dialog --stdout                         \
   --backtitle 'DLDAP - Alterar Grupo'      \
   --title "Alterar descrição do grupo: $group"                         \
   --inputbox '\n\nInsira a nova descrição: '  \
   13 50 )

######################################
## Verificando se o usuário apertou ESC ou em Cancel
######################################
if [ $? -ne 0 ];then
	src/dldap-groups.sh
	exit
fi

#########################################
## Verificando se o usuário deixou o campo vazio
#########################################
if [ -z "$desc" ];
then
        dialog --backtitle 'DLDAP - Alterar Grupo' --title 'Erro!' --msgbox 'O novo valor não pode ser vazio!' 6 40
        src/dldap-groups.sh
        exit
fi

######################################################
## Removendo possíveis acentos da descrição fornecida
######################################################
desc=$(src/adjust-text.sh "$desc" noaccent)

######################################################
## Gerando o arquivo ldif para alteração de descrição do grupo
######################################################
cat src/group/ldifs/add-description.ldif | sed "s/<group>/$group/" | sed "4c\description: $desc" > $group.ldif

######################################################
## Executando a modificação atavés do ldapmodify
######################################################
ldapmodify -x -D "$user" -H ldap://ldap1 -f $group.ldif -w $password > /dev/null

################################################
## Gerando o log para a operação realizada e movendo o arquivo ldif
################################################
echo "$(date "+%H:%M") - MODIFY DESCRIPTION FROM GROUP $group TO $desc" >> logs/$(date "+%d%m%Y")-dldap.log
mv $group.ldif logs/ldifs

################################
## Notificando o usuário do fim da operação, realizada com sucesso.
################################
dialog                                            \
  --backtitle 'DLDAP - Alterar Grupo'                 \
   --title 'Sucesso!'                             \
   --msgbox "A descrição do grupo $group foi atualizada."  \
   6 40

#######################
## Voltando a tela de gerenciamento de grupos
#######################
src/dldap-groups.sh
