#!/bin/bash

## Obtendo o nome do usuário passado como parâmetro
user=$1

## Obtendo todos os grupos dos quais o usuário não é membro
groups=$(src/user/select-groups.sh add $user "Selecione um ou mais grupos:" "DLDAP - Alterar Usuário")

## Verificando se existe algum grupo que o usuário não pertença ou se não foi selecionado
## nenhum grupo
if [ "$groups" = "null" ]; then
	src/user/modify-user.sh
	exit
fi

## Adicionando o usuário nos grupos selecionados
for group in $groups
do
	src/group/add-or-del-user-group.sh add $group $user
done

## Informando ao usuário que a operação foi realizada
dialog                                            \
  --backtitle 'DLDAP - Alterar Usuário'                 \
   --title 'Sucesso!'                             \
   --msgbox 'Usuário alterado com êxito!'  \
   6 40

## Retornando a tela de gerência de usuários
src/dldap-users.sh
