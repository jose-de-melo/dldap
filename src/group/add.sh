#!/bin/bash

#################
## Obtendo as informações da base LDAP
#################
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

################
## Lendo o nome do novo grupo
################
cn=$( dialog --stdout                         \
   --backtitle 'DLDAP - Adicionar Grupo'      \
   --title 'Novo Grupo:'                         \
   --inputbox '\n\nNome (cn): '  \
   13 50 )

################
## Verificando se o usuário apertou ESC ou em Cancel 
################
if [ $? -ne 0 ]; then
	src/dldap-groups.sh
	exit
fi

###############
## Verificando se o usuário deixou o campo em branco
###############
if [ -z "$cn" ] ;
then
	src/message.sh "DLDAP - Adicionar Grupo" "Erro" "O nome do grupo não pode ser nulo!"
	src/dldap-groups.sh
	exit
fi

##############
## Verificando se o nome fornecido já está sendo usado na base
##############
ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "$base" "(objectClass=posixGroup)" -w $password | grep "cn: $cn" > /dev/null

if [ $? -eq 0 ] ;
then
	src/message.sh "DLDAP - Adicionar Grupo" "Erro" "O nome fornecido já está sendo utilizado na base!"	
	src/dldap-groups.sh
	exit
fi

###################################
## Lendo a descrição do novo grupo
###################################
desc=$( dialog --stdout                         \
   --backtitle 'DLDAP - Adicionar Grupo'      \
   --title 'Novo Grupo:'                         \
   --inputbox '\n\nDescrição do grupo: '  \
   13 50 )


######################################################
## Verificando se o usuário apertou ESC ou em Cancel
######################################################
if [ $? -ne 0 ];then
	src/dldap-groups.sh
	exit
fi

##################################################
## Verificando se o usuário deixou o campo vazio
##################################################
if [ -z "$desc" ] ;
then
        src/message.sh "DLDAP - Adicionar Grupo" "Erro" "A descrição do grupo não pode ser vazia!"
        src/dldap-groups.sh
        exit
fi

#########################
## Buscando os usuários cadastrados na base LDAP
#########################
users=$(ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "$base" "(objectClass=posixAccount)" uid -w $password | grep uid: | cut -d" " -f2)


########################
## Array utilizado para facilitar a manipulação das opções do menu a seguir
########################
LIST=()
for user in $(echo $users)
do
        DESC=''
        LIST+=( $user "$DESC" off)
done

#########################
## Exibindo a lista de usuários
#########################
users=$( dialog --stdout \
        --backtitle "DLDAP - Adicionar Grupo" \
        --title "Selecionar usuários" \
        --separate-output \
        --checklist 'Selecione no mínimo um usuário criar o grupo:' 0 40 0 \
        "${LIST[@]}" \
        )

#########################
## Verificando se o usuário apertou ESC ou em Cancel
#########################
if [ $? -ne 0 ];then
	src/dldap-groups.sh
	exit
fi

######################
## Verificando se ao menos um usuário foi selecionado
######################
if [ -z "$users" ];
then
	src/message.sh "DLDAP - Adicionar Grupo" "Erro" "Selecione ao menos um usuário ao criar um novo grupo!"
        src/dldap-groups.sh
        exit
fi

#####################
## Obtendo o gid que será usado pelo novo grupo
#####################
gid=$(expr $(src/group/get-greatest-gid.sh) + 1)

#####################
## Gerando o arquivo ldif do novo grupo
#####################
cat src/group/ldifs/add-group.ldif | sed "s/<base>/$base/" | sed "s/<cn>/$cn/" | sed "s/<desc>/$desc/" | sed "s/<gid>/$gid/" >> $cn.ldif
for user in $users
do
	echo "uniqueMember: uid=$user,ou=Usuarios,$base" >> $cn.ldif
done
echo "" >> $cn.ldif

####################
## Realizando a adição do novo grupo a base
####################
ldapadd -x -D "$userBase" -H ldap://ldap1 -f $cn.ldif -w $password > /dev/null

#####################
## Exibindo uma mensagem de confirmação da adição
#####################
src/message.sh "DLDAP - Adicionar Grupo" "Sucesso" "Grupo adicionado com sucesso!"

#####################
## Gerando log para a operação e movendo o ldif do novo grupo
#####################
echo "$(date "+%H:%M") - ADD GROUP $cn" >> logs/$(date "+%d%m%Y")-dldap.log
mv $cn.ldif logs/ldifs

####################
## Voltando ao menu anterior
####################
src/dldap-groups.sh
