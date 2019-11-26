#!/bin/bash

password=$(cat .password)

hosts=$(ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "ou=Maquinas,dc=jose,dc=labredes,dc=info" "objectClass=nisNetGroup" -w $password | grep cn: | cut -d" " -f2)


LIST=()

for h in $(echo $hosts)
do
        DESC=''
        LIST+=( $h "$DESC" off)
done

host=$( dialog --stdout \
        --backtitle "DLDAP - Gerenciamento de Máquinas" \
        --title "Excluir Máquina" \
        --radiolist 'Selecione uma máquina para excluir:' 0 40 0 \
        "${LIST[@]}" \
       )

if [ $? -ne 0 ]; then
        src/dldap-hosts.sh
        exit
fi

dialog --backtitle "DLDAP - Excluir Máquina: $host" --title 'Confirmar Exclusão' --yesno "Confirmar a exclusão da máquina $host?\n\nATENÇÃO: Ao apagar a máquina, todos as interfaces cadastradas para a mesma também serão removidas da base." 10 60

if [ $? -eq 0 ];then
	src/host/remove-host.sh $host
	dialog                                            \
  --backtitle 'DLDAP - Excluir Máquina'                 \
   --title 'INFO'                             \
   --msgbox "A máquina $host foi removida!"  \
   6 40
fi

src/dldap-hosts.sh
