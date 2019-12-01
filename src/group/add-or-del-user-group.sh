#!/bin/bash

#########################################################
## Obtendo as informações da base LDAP
#########################################################
base=$(./getconfig.sh base)
user=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)



###########
## Operação a ser executada. Opções: add ou delete
###########
operation=$1

###########
## Grupo a ser modificado
###########
group=$2

###########
## Usuário a ser inserido ou removido do grupo
###########
uid=$3


##########
## Montando o arquivo ldif
##########
cat src/group/ldifs/add-user.ldif | sed "s/<base>/$base/" | sed "s/<operation>/$operation/"  | sed "s/<group>/$group/" | sed "s/<uid>/$uid/" >> $operation-$uid-$group.ldif


#############
## Executando a alteração através do comando ldapmodify
#############
ldapmodify -x -D "$user" -H ldap://ldap1 -f $operation-$uid-$group.ldif -w $password >> /dev/null

#############
## Gerando o log para operação executada
#############
if [ $operation = "add" ];
then
	echo "$(date "+%H:%M") - ADD MEMBER $uid TO GROUP $group" >> logs/$(date "+%d%m%Y")-dldap.log
else
	echo "$(date "+%H:%M") - DELETE MEMBER $uid FROM GROUP $group" >> logs/$(date "+%d%m%Y")-dldap.log
fi

#############
## Movendo o arquivo ldif gerado para a pasta de logs
#############
mv $operation-$uid-$group.ldif logs/ldifs/
