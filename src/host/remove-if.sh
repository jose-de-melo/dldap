#!/bin/bash

password=$(cat .password)
host=$1

ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "cn=$host,ou=Maquinas,dc=jose,dc=labredes,dc=info" "(objectClass=ipHost)" -w $password > tmp

ifs=$(cat tmp | grep "dn: cn=" | cut -d" " -f2 | cut -d"," -f1 | cut -d"=" -f2)

LIST=()

DESC=''
for int in $(echo $ifs)
do
        LIST+=( $int "$DESC" off)
done

if [ ${#LIST[@]} -eq 0 ];
then
        dialog                                            \
  --backtitle 'DLDAP - Alterar Máquina'                 \
   --title 'INFO'                             \
   --msgbox "\nA máquina $host não possui nenhuma interface cadastrada! \n"  \
   8 50
        src/dldap-hosts.sh
        rm -rf tmp
        exit
fi

rm -rf tmp

interface=$( dialog --stdout --cancel-label "Cancelar" \
        --backtitle "DLDAP - Alterar Máquina" \
        --title "Remover interface" \
        --radiolist 'Selecione uma interface' 0 40 0 \
        "${LIST[@]}" \
        )


if [ $? -ne 0 ]; then
        src/dldap-hosts.sh
        exit
fi

dialog --backtitle "DLDAP - Alterar Máquina: $host" --title 'Excluir Interface' --yesno "Confirma a exclusão da interface $interface da máquina $host ?" 7 45

if [ $? -eq 0 ];then
        src/host/del-if.sh $host $interface
        dialog                                            \
  --backtitle 'DLDAP - Alterar Máquina'                 \
   --title 'INFO'                             \
   --msgbox "A interface $interface da máquina $host foi removida!"  \
   6 40
fi

src/dldap-hosts.sh
