#!/bin/bash

password=$(cat .password)
cn=$1

ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "cn=$cn,ou=Maquinas,dc=jose,dc=labredes,dc=info" "(objectClass=ipHost)" -w $password > tmp

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
  --backtitle 'DLDAP - Consultar Máquina'                 \
   --title 'INFO'                             \
   --msgbox "\nA máquina $cn não possui nenhuma interface cadastrada! \n"  \
   8 50
        src/dldap-hosts.sh
	rm -rf tmp
        exit
fi





interface=$( dialog --stdout --cancel-label "Cancelar" \
        --backtitle "DLDAP - Consultar Máquina" \
        --title "Selecione uma interface:" \
        --radiolist '' 0 40 0 \
        "${LIST[@]}" \
        )


if [ $? -ne 0 ]; then
	src/dldap-hosts.sh
	exit
fi

if [ -z "$interface" ]; then
	dialog --backtitle "DLDAP - Consultar Máquina" --title "Erro" --msgbox "\nSelecione uma interface para consultar!" 8 50
	src/dldap-hosts.sh
	exit
fi

ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "cn=$interface,cn=$cn,ou=Maquinas,dc=jose,dc=labredes,dc=info" "(objectClass=ipHost)" -w $password > tmp

ipHost=$(cat tmp | grep ipHostNumber: | cut -d" " -f2)
ipNet=$(cat tmp | grep ipNetworkNumber: | cut -d" " -f2)
ipNetMask=$(cat tmp | grep ipNetmaskNumber: | cut -d" " -f2)
mac=$(cat tmp | grep macAddress: | cut -d" " -f2)
desc=$(cat tmp | grep description: | cut -d" " -f2-)

dialog --backtitle "DLDAP - Consultar Máquina"      \
   --title "Informações da interface $interface do host $cn"   \
   --msgbox "\nDescrição: $desc\nIP do Host: $ipHost\nIP da Rede: $ipNet\nMáscara da Rede: $ipNetMask\nEndereço MAC: $mac\n" 12 70



rm -rf tmp
src/dldap-hosts.sh
