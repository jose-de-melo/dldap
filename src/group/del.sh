#/bin/bash


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

group=$( dialog --stdout \
        --backtitle "DLDAP - Excluir Grupo" \
        --title "Excluir Grupo" \
        --radiolist 'Selecione um grupo:' 0 40 0 \
        "${LIST[@]}" \
        )


if [ $? -ne 0 ]; then
	src/dldap-groups.sh
	exit
fi

dialog --backtitle "DLDAP - Excluir Grupo" --title 'Confirmar Exclusão' --yesno "\n\nConfirmar exclusão do grupo $group?" 10 40

if [ $? = 0 ]; then
	 ldapdelete -x -D 'cn=admin,dc=jose,dc=labredes,dc=info' -H ldap://ldap1 "cn=$group,ou=Grupos,dc=jose,dc=labredes,dc=info" -w $password > /dev/null
	dialog --backtitle "DLDAP - Excluir Usuário" --title "Exclusão Realizada" --ok-label "Voltar" --msgbox "\nO grupo $group foi excluído!" 8 40
	src/dldap-groups.sh
else
	dialog --backtitle "DLDAP - Excluir Usuário" --title "Exlcusão cancelada" --ok-label "Voltar" --msgbox "\nO grupo $group não será excluído!" 8 40
	src/dldap-groups.sh
fi
