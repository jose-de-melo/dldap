#!/bin/bash

user=$1

groups=$(src/user/select-groups.sh delete $user "Selecione o grupo para remover o usuário" "DLDAP - Alterar Usuário")


if [ "$groups" = "null" ]; then
	src/user/modify-user.sh
	exit
fi


for group in $groups
do
	src/group/add-or-del-user-group.sh delete $group $user
done


src/message.sh "DLDAP - Alterar Usuário" "Sucesso!" "Usuário alterado com êxito!"

src/user/modify-user.sh
