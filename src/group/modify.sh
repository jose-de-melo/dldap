#!/bin/bash

password=$(cat .password)

groups=$(ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "dc=jose,dc=labredes,dc=info" "(objectClass=posixGroup)" cn -w $password | grep cn: | cut -d" " -f2)


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

group=$( dialog --stdout --cancel-label "Voltar" \
        --backtitle "DLDAP - Alterar Grupo" \
        --title "Alterar Grupo" \
        --radiolist 'Selecione um grupo:' 0 40 0 \
        "${LIST[@]}" \
        )


if [ $? -ne 0 ];then
	src/dldap-groups.sh
	exit
fi

resposta=$(
      dialog --stdout --cancel-label "Voltar"               \
             --backtitle "DLDAP - Alterar Grupo"      \
             --title "Alterar Grupo: $group"  \
             --menu 'Escolha um atributo para editar:' \
            0 0 0                   \
            1 'Alterar Descrição'     \
            2 'Usuários do Grupo'        \
            0 'Cancelar'                )

if [ $? -ne 0 ]; then
        src/dldap-groups.sh
        exit
fi

case "$resposta" in
         1) src/group/modify-description.sh $group ;;
         2) src/group/manage-users.sh $group ;;
         0) src/dldap-users.sh ;;
esac
