#!/bin/bash

password=$(cat .password)


output=$( ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "dc=jose,dc=labredes,dc=info" "(objectClass=posixAccount)" -w $password | grep uid: | cut -d" " -f2 )


LIST=()

count=0
for linha in $(echo $output)
do	
        DESC=''
	if [ $count -eq 0 ];
	then
        	LIST+=( $linha "$DESC" on)
		count=1
	else
		LIST+=( $linha "$DESC" off)
	fi
done

user=$( dialog --stdout \
        --backtitle "DLDAP - Alterar Usuário" \
        --title "Selecionar Usuário" \
        --radiolist '' 0 40 0 \
        "${LIST[@]}" \
)

if [ $? -ne 0 ]; then
	src/dldap-users.sh
	exit
fi

resposta=$(
      dialog --stdout               \
	     --backtitle "DLDAP - Alterar Usuário"	\
             --title "Alterar Usuário: $user"  \
             --menu 'Escolha um atributo para editar:' \
            0 0 0                   \
            1 'Alterar Gecos'  \
            2 'Alterar Senha'     \
            3 'Gerenciar Grupos'        \
            0 'Cancelar'                )

if [ $? -ne 0 ]; then
	src/dldap-users.sh
	exit
fi

case "$resposta" in
         1) src/user/modify-gecos-user.sh $user ;;
         2) src/user/modify-password-user.sh $user ;;
         3) src/user/manage-groups-user.sh $user ;;
         0) src/dldap-users.sh ;;
esac
