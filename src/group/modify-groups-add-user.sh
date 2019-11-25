#!/bin/bash

group=$1
password=$(cat .password)

list=$(ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "ou=Usuarios,dc=jose,dc=labredes,dc=info" "(objectClass=posixAccount)" uid -w $password | grep uid: | cut -d" " -f2)


ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "ou=Grupos,dc=jose,dc=labredes,dc=info" "(&(objectClass=posixGroup)(cn=$group))" uniqueMember -w $password > tmp


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

rm -rf tmp


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
	


users=$( dialog --stdout \
        --backtitle "DLDAP - Alterar Grupo" \
        --title "Adicionar Usuários : $group" \
        --separate-output \
        --checklist '' 0 40 0 \
        "${LIST[@]}" \
        )

if [ $? -ne 0 ]; then
	src/dldap-groups.sh
	exit
fi

for user in $users
do
	src/group/add-or-del-user-group.sh add $group $user
done


dialog                                            \
  --backtitle 'DLDAP - Alterar Grupo'                 \
   --title 'Sucesso!'                             \
   --msgbox "\nNúmero de membros do grupo $group atualizado."  \
   8 40

src/dldap-groups.sh











