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

if [ ${#LIST[@]} -eq 3 ];
then
        dialog                                            \
  --backtitle 'DLDAP - Alterar Grupo'                 \
   --title 'Erro'                             \
   --msgbox "\nO grupo $group possui apenas um membro, nesse caso, a remoção do mesmo não pode ser realizada para não afetar a integridade do objeto !\n"  \
   10 50
        src/dldap-groups.sh
        exit
fi



user=$( dialog --stdout \
        --backtitle "DLDAP - Alterar Grupo" \
        --title "Remover Membro : $group" \
        --radiolist '' 10 50 0 \
        "${LIST[@]}" \
        )

if [ $? -ne 0 ]; then
        src/dldap-groups.sh
        exit
fi

src/group/add-or-del-user-group.sh delete $group $user


dialog                                            \
  --backtitle 'DLDAP - Alterar Grupo'                 \
   --title 'Sucesso!'                             \
   --msgbox "\nO usuário $user foi removido do grupo $group !"  \
   8 40

src/dldap-groups.sh
