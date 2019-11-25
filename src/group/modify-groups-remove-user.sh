#!/bin/bash

password=$(cat .password)

group=$1

list=$(ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "ou=Grupos,dc=jose,dc=labredes,dc=info" "(&(objectClass=posixGroup)(cn=$group))" uniqueMember -w $password | grep uniqueMember | cut -d" " -f2 | cut -d"," -f1 | cut -d"=" -f2)

LIST=()

first=0
DESC=''
for linha in $(echo $list)
do
	if [ $first -eq 0 ];then
        	LIST+=( $linha "$DESC" on)
                first=1
        else
                LIST+=( $linha "$DESC" off)
	fi
done


if [ ${#LIST[@]} -eq 0 ];
then
        dialog                                            \
  --backtitle 'DLDAP - Alterar Grupo'                 \
   --title 'Erro'                             \
   --msgbox "\nO grupo $group não possui membros !"  \
   8 40
        src/dldap-groups.sh
        exit
fi

users=$( dialog --stdout \
        --backtitle "DLDAP - Alterar Grupo" \
        --title "Remover Membros : $group" \
        --separate-output \
        --checklist 'AVISO: Ao menos um usuário deve ser mantido como membro do grupo, caso você tente remover todos os usuários, o último da listagem será mantido como membro do grupo.' 10 50 0 \
        "${LIST[@]}" \
        )

if [ $? -ne 0 ]; then
        src/dldap-groups.sh
        exit
fi

for user in $users
do
        src/group/add-or-del-user-group.sh delete $group $user > /dev/null
done


dialog                                            \
  --backtitle 'DLDAP - Alterar Grupo'                 \
   --title 'Sucesso!'                             \
   --msgbox "\nNúmero de membros do grupo $group atualizado."  \
   8 40

src/dldap-groups.sh
