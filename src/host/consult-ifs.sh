#!/bin/bash

## Obtendo os dados da base LDAP
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Obtendo o nome do host
cn=$1

## Buscando as interfaces da máquina
ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "cn=$cn,ou=Maquinas,$base" "(objectClass=ipHost)" -w $password > tmp

## Gerando a lista com as interfaces do host
ifs=$(cat tmp | grep "dn: cn=" | cut -d" " -f2 | cut -d"," -f1 | cut -d"=" -f2)
LIST=()
DESC=''
for int in $(echo $ifs)
do
        LIST+=( $int "$DESC" off)
done

## Verificando se o host possui alguma interface cadastrada
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

## Exibindo um radiolist com as interfaces da máquina
interface=$( dialog --stdout --cancel-label "Cancelar" \
        --backtitle "DLDAP - Consultar Máquina" \
        --title "Selecione uma interface:" \
        --radiolist '' 0 40 0 \
        "${LIST[@]}" \
        )

## Verificando se o usuário apertou ESC ou em Cancel
if [ $? -ne 0 ]; then
	src/dldap-hosts.sh
	exit
fi

## Verificando se o usuário selecionou uma interface
if [ -z "$interface" ]; then
	dialog --backtitle "DLDAP - Consultar Máquina" --title "Erro" --msgbox "\nSelecione uma interface para consultar!" 8 50
	src/dldap-hosts.sh
	exit
fi

## Buscando os dados da interface selecionada e armazenando em um arquivo temporário
ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "cn=$interface,cn=$cn,ou=Maquinas,$base" "(objectClass=ipHost)" -w $password > tmp

## Separando os dados obtidos na pesquisa acima
ipHost=$(cat tmp | grep ipHostNumber: | cut -d" " -f2)
ipNet=$(cat tmp | grep ipNetworkNumber: | cut -d" " -f2)
ipNetMask=$(cat tmp | grep ipNetmaskNumber: | cut -d" " -f2)
mac=$(cat tmp | grep macAddress: | cut -d" " -f2)
desc=$(cat tmp | grep description: | cut -d" " -f2-)

## Removendo o arquivo temporário
rm -rf tmp

## Exibindo as informações da máquina
dialog --backtitle "DLDAP - Consultar Máquina"      \
   --title "Informações da interface $interface do host $cn"   \
   --msgbox "\nDescrição: $desc\nIP do Host: $ipHost\nIP da Rede: $ipNet\nMáscara da Rede: $ipNetMask\nEndereço MAC: $mac\n" 12 70

## Retornando a tela de gerência de máquinas
src/dldap-hosts.sh
