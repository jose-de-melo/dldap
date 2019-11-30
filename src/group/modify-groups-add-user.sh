#!/bin/bash

#########################################
## Obtendo os dados da base LDAP
#########################################
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

########################################
## Obtendo o grupo passado como parâmetro
########################################
group=$1

###################################################
## Obtendo todos os usuários cadastrados na base  #
###################################################
list=$(ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "ou=Usuarios,$base" "(objectClass=posixAccount)" uid -w $password | grep uid: | cut -d" " -f2)

###########################################################################
## Buscando os usuários que são membros do grupo fornecido como parâmetro 
###########################################################################
ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "ou=Grupos,$base" "(&(objectClass=posixGroup)(cn=$group))" uniqueMember -w $password > tmp

##########################################################################################
## Montando a lista de usuários que cadastrados na base mas que não são membros do grupo
##########################################################################################
LIST=()
first=0
DESC=''
for linha in $(echo $list)
do
	cat tmp | grep "uniqueMember: uid=$linha" > /dev/null

	if [ $? -eq 1 ]; then
        	if [ $first -eq 0 ];then
                	LIST+=( $linha "$DESC" on)
			first=1
	        else
                	LIST+=( $linha "$DESC" off)
	        fi
	fi
done

## Removendo o arquivo temporário usado para armazenar a lista de membros do grupo
rm -rf tmp


#################################################################
## Verificando se existe algum usuário cadastrado na base que já não seja membro do grupo
#################################################################
if [ ${#LIST[@]} -eq 0 ];
then
	dialog                                            \
  --backtitle 'DLDAP - Alterar Grupo'                 \
   --title 'Erro'                             \
   --msgbox "\nNão foi encontrado nenhum usuário que não pertença ao grupo $group!"  \
   8 40
	src/dldap-groups.sh
	exit
fi
	
#################################
## Exibindo o checklist com a lista gerada anteriormente
#################################
users=$( dialog --stdout \
        --backtitle "DLDAP - Alterar Grupo" \
        --title "Adicionar Membros : $group" \
        --separate-output \
        --checklist '' 0 40 0 \
        "${LIST[@]}" \
        )

################################
## Verificando se o usuário apertou ESC ou em Cancel
################################
if [ $? -ne 0 ]; then
	src/dldap-groups.sh
	exit
fi

#####################################
## Realizando a adição dos usuários selecionados ao grupo
#####################################
for user in $users
do
	src/group/add-or-del-user-group.sh add $group $user
done

######################################
## Informando que a operação foi finalizada com sucesso
######################################
dialog                                            \
  --backtitle 'DLDAP - Alterar Grupo'                 \
   --title 'Sucesso!'                             \
   --msgbox "\nNúmero de membros do grupo $group atualizado."  \
   8 40

#########################################
## Voltando a tela de gerenciamento de grupos
#########################################
src/dldap-groups.sh
