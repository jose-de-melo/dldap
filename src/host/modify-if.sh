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

interface=$( dialog --stdout --cancel-label "Cancelar" \
        --backtitle "DLDAP - Alterar Máquina" \
        --title "Selecione uma interface:" \
        --radiolist '' 0 40 0 \
        "${LIST[@]}" \
        )


if [ $? -ne 0 ]; then
        src/dldap-hosts.sh
        exit
fi

if [ -z "$interface" ]; then
        dialog --backtitle "DLDAP - Alterar Máquina" --title "Erro" --msgbox "\nSelecione uma interface para alterar!" 8 50
        src/dldap-hosts.sh
        exit
fi


op=$( dialog --cancel-label "Voltar" --backtitle 'DLDAP - Gerenciamento de Máquinas' \
        --stdout                 \
        --menu 'Selecione uma opção:'       \
        0 0 0                    \
        1 "$host > $interface : Alterar Descrição" \
        2 "$host > $interface : Alterar IP" \
        3 "$host > $interface : Alterar Máscara da Rede" \
        4 "$host > $interface : Alterar IP da Rede" \
	5 "$host > $interface : Alterar endereço MAC" \
        0 'Voltar'  )

if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

case "$op" in
        1) src/host/att-ifs.sh $host $interface description "Nova descrição: ";;
	2) src/host/att-ifs.sh $host $interface ipHostNumber "Novo IP da Interface: ";;
	3) src/host/att-ifs.sh $host $interface ipNetmaskNumber "Nova máscara da rede: ";;
	4) src/host/att-ifs.sh $host $interface ipNetworkNumber "Novo IP da rede: ";;
	5) src/host/att-ifs.sh $host $interface macAddress "Novo endereço MAC da Interface: ";;
        0) ./dldap-hosts.sh ;;
esac







