#!/bin/bash

## Obtendo o nome do usuário passado como parâmetro
user=$1

## Listando todos os grupos dos quais o usuário é membro
groups=$(src/user/select-groups.sh delete $user "Selecione o grupo para remover o usuário" "DLDAP - Alterar Usuário")

## Verificando se o usuário está em algum grupo ou se nenhum grupo foi selecionado para ser 
## excluído
if [ "$groups" = "null" ]; then
	src/dldap-users.sh
	exit
fi

## Removendo o usuário dos grupos selecionados anteriormente
for group in $groups
do
	src/group/add-or-del-user-group.sh delete $group $user
done

## Informando ao usuário que a operação foi realizada
src/message.sh "DLDAP - Alterar Usuário" "Sucesso!" "Usuário alterado com êxito!"

## Retornando a tela de gerência de usuários
src/dldap-users.sh
