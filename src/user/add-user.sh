#!/bin/bash

## Obtendo os dados da base ldap
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
basePass=$(./getconfig.sh userPassword)

# Obtendo o uid do novo usuário
uid=$( dialog --stdout                         \
   --backtitle 'DLDAP - Adicionar Usuário'      \
   --title 'Novo Usuário'                         \
   --inputbox '\n\nUsername (uid): '  \
   13 50 )


if [ $? -ne 0 ];then
	src/dldap-users.sh
	exit
fi

## Verificando se o usuário não deixou o campo em branco
if [ -z $uid ];
then
	dialog                                            \
  --backtitle 'DLDAP - Adicionar Usuário'                 \
   --title 'Erro!'                             \
   --msgbox 'UID não pode ser vazio!'  \
   6 40
	src/dldap-users.sh
	exit
fi

# Verificando se o uid fornecido já existe na base de dados
ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "$base" "(objectClass=posixAccount)" -w $basePass | grep "uid: $uid"

if [ $? -eq 0 ]; then
		dialog --backtitle 'DLDAP - Adicionar Usuário' --title 'Erro!' --msgbox 'O UID fornecido já está sendo usado!' 6 40
        	src/dldap-users.sh
		exit
fi


## Obtendo o gecos do novo usuário
gecos=$( dialog --stdout                         \
   --backtitle 'DLDAP - Adicionar Usuário'      \
   --title 'Novo Usuário'                         \
   --inputbox '\n\nGecos: '  \
   13 50 )

## Verificando se o usuário apertou ESC ou em Cancel
if [ $? -ne 0 ];then
	src/dldap-users.sh
	exit
fi


## Verificando se o valor lido não está vazio
if [ -z $(echo $gecos | awk '{ print $NF}') ];
then
	dialog --backtitle 'DLDAP - Adicionar Usuário' --title 'Erro!' --msgbox 'O campo Gecos é obrigatório e não pode ser vazio!' 6 40
	src/dldap-users.sh
        exit
fi



## Obtendo a senha para o novo usuário.
password=$( dialog --stdout                   \
   --backtitle 'DLDAP - Adicionar Usuário'      \
   --title 'Novo Usuário'                         \
   --passwordbox '\n\nSenha: '  \
   13 50 )


## Verificando se o usuário apertou ESC ou em Cancel
if [ $? -ne 0 ]; then
	src/dldap-users.sh
	exit
fi

## Verificando se o valor lido não está vazio
if [ -z $password ];
then
	dialog --backtitle 'DLDAP - Adicionar Usuário' --title 'Erro!' --msgbox 'A senha fornecida não é válida!' 6 40

	src/dldap-users.sh
        exit
fi

## Removendo acentos e letras maiscúlas
uid=$(src/adjust-text.sh $uid double)

## Tratando o gecos fornecido
gecos=$(src/adjust-text.sh "$gecos" noaccent )

sn=$(src/adjust-text.sh "$gecos" tolower | awk '{ print $NF  }')

## Gerando o uid para o novo usuário
uidNumber=$(expr $(src/user/get-greatest-uid.sh) + 1)

## Gerando a data da última alteração da senha, o dia corrente no caso
date=$(expr $(date +"%s") / 86400)

## Gerando a senha criptada para o novo usuário
password=$(python -c 'import crypt; import sys;print crypt.crypt(sys.argv[1],crypt.mksalt(crypt.METHOD_SHA512))' $password )

## Montando o arquivo ldif
cat src/user/ldifs/user.ldif | sed "s/<base>/$base/"| sed "s/<uid>/$uid/" | sed "s/<date>/$date/" | sed "s/<cn>/$uid/" | sed "s/<sn>/$sn/" | sed "s/<id>/$uidNumber/" >> src/user/ldifs/tmp.ldif

cat src/user/ldifs/tmp.ldif | sed "12c\gecos: $gecos" | sed "13c\userPassword: {crypt}$password" >> src/user/ldifs/$uid.ldif


## Executando a adição
src/user/ldap-add-user.sh $uid

## Verificando se o usuário deseja inserir o usuário em algum grupo já cadastrado
dialog --backtitle "DLDAP - Adicionar Usuário" --yesno 'Deseja inserir o usuário a um grupo já cadastrado?' 10 30 

if [ $? -eq 0 ];
then
	## Obtendo os grupos que o usuário deseja inserir
	groups=$(src/user/select-groups.sh add $uid "Selecionar Grupo(s)" "DLDAP - Adicionar Usuário")

	
	## Verificando se o usuário selecionou algum grupo ou se existe algum grupo cadastrado
	if [ "$groups" != "null" ];then
		for group in $groups
		do
			## Executando a adição do usuário a um grupo selecionado
			src/group/add-or-del-user-group.sh add $group $uid

			## Gerando log para a operação
			echo "$(date "+%H:%M") - ADD MEMBER $uid TO GROUP $group" >> logs/$(date "+%d%m%Y")-dldap.log
		done
	fi
fi	

## Movendo o arquivo ldif criado
mv src/user/ldifs/$uid.ldif logs/ldifs

## Removendo os arquivos temporários criados
rm -rf src/user/ldifs/tmp.ldif
rm -rf awkvar.outs

## Informando ao usuário que a operação foi realizada
dialog                                            \
  --backtitle 'DLDAP - Adicionar Usuário'                 \
   --title 'Sucesso!'                             \
   --msgbox 'Usuário adicionado com êxito!'  \
   6 40

## Voltando a tela de gerência de usuários
src/dldap-users.sh
