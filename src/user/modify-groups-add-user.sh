#!/bin/bash

user=$1

groups=$(src/user/select-groups.sh add $user "Selecione um grupo par adicionar ao usuário" "DLDAP - Alterar Usuário")

[ "$groups" = "null" ] && src/user/modify-user.sh && exit


for group in $groups
do
	src/group/add-or-del-user-group.sh add $group $user
done


dialog                                            \
  --backtitle 'DLDAP - Alterar Usuário'                 \
   --title 'Sucesso!'                             \
   --msgbox 'Usuário alterado com êxito!'  \
   6 40

src/user/modify-user.sh
