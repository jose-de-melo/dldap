#!/bin/bash

## Obtendo as informações da base
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Obtendo o nome do usuário passado como parâmetro
user=$1

## Solicitando a confirmação para excluir o usuário
dialog --backtitle "DLDAP - Excluir Usuário: $user" --title 'Confirmar Exclusão' --yesno "Confirmar exclusão do usuário $user?\n\nATENÇÃO: O usuário será excluído por completo, incluindo o grupo de mesmo nome" 10 60

## Verificando se o usuário confirmou a exclusão
if [ $? = 0 ]; then
	
	## Executando a deleção do usuário
        ldapdelete -x -D "$userBase" -H ldap://ldap1 "uid=$user,ou=Usuarios,$base" -w $password >> /dev/null

	## Gerando log para a operação realizada
	echo "$(date "+%H:%M") - DELETE USER $user" >> logs/$(date "+%d%m%Y")-dldap.log

	## Verificando se o grupo cadastrado na inserção do usuário ainda existe na base
	ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "ou=Grupos,$base" "(&(objectClass=posixGroup)(cn=$user))" cn -w $password | grep $user > /dev/null

	## Se o grupo ainda existir, o mesmo será removido agora
	if [ $? = 0 ];
	then
		## Removendo o grupo do usuário
		ldapdelete -x -D "$userBase" -H ldap://ldap1 "cn=$user,ou=Grupos,$base" -w $password >> /dev/null

		## Gerando log para a operação realizada
		echo "$(date "+%H:%M") - DELETE GROUP $user" >> logs/$(date "+%d%m%Y")-dldap.log
	fi
fi
