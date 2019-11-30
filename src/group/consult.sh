#!/bin/bash

########################
## Obtendo as informações da base
########################
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

########################
## Obtendo os grupos da base LDAP
########################
groups=$(ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "$base" "(objectClass=posixGroup)" cn -w $password | grep cn: | cut -d" " -f2)


#########################
## Montando os opções do radiolist
#########################
LIST=()
first=true
DESC=''
for linha in $(echo $groups)
do
	if [ $first ];then
       		LIST+=( $linha "$DESC" on)
	else
		LIST+=( $linha "$DESC" off)
	fi
done

#########################
## Exibindo o radiolist com os grupos obtidos
#########################
group=$( dialog --stdout \
        --backtitle "DLDAP - Consultar Grupo" \
        --title "Consultar Grupo" \
        --radiolist 'Selecione um grupo:' 0 40 0 \
        "${LIST[@]}" \
        )

##############################
## Verificando se o usuário apertou ESC ou em Cancel
##############################
if [ $? -ne 0 ]; then
	src/dldap-groups.sh
	exit
fi

####################################
## Obtendo os dados do grupo selecionado e armazenando em um arquivo temporário
####################################
ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "$base" "(&(objectClass=posixGroup)(cn=$group))" -w $password > tmp


####################################
## Separando as informações armazenadas no arquivo temporário
####################################
description=$( cat tmp | grep "description:" | cut -d" " -f2-)
members=$(cat tmp | grep "uniqueMember:" | cut -d":" -f2 | cut -d"," -f1 | cut -d"=" -f2)
strMember=''
first=true
for member in $members
do
	if [ "$first" == "true" ];
	then
		strMember+=$(echo "$member")
		first=false
	else
		strMember=$(echo "$member, $strMember")
	fi
done

####################################
## Exibindo os dados exibidos em uma caixa de texto
####################################
dialog --backtitle "DLDAP - Consultar Grupo: $group"      \
   --title 'Dados do Grupo'   \
   --msgbox "\nNome (cn): $group\nDescrição: $description\nMembros: $strMember" 10 60

#################################
## Removendo o arquivo temporário
#################################
rm -rf tmp

################################
## Voltando à tela anterior
################################
src/dldap-groups.sh
