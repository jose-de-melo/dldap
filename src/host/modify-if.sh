#!/bin/bash

## Obtendo as informações da base
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Obtendo o nome da máquina recebido como parâmetro
host=$1

## Buscando as interfaces do host recebido como parâmetro
ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "cn=$host,ou=Maquinas,$base" "(objectClass=ipHost)" -w $password > tmp

## Gerando a lista com as interfaces 
ifs=$(cat tmp | grep "dn: cn=" | cut -d" " -f2 | cut -d"," -f1 | cut -d"=" -f2)
LIST=()
DESC=''
for int in $(echo $ifs)
do
        LIST+=( $int "$DESC" off)
done

## Verificando se o host possui alguma interface
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

## Exibindo a lista de interfaces do host
interface=$( dialog --stdout --cancel-label "Cancelar" \
        --backtitle "DLDAP - Alterar Máquina" \
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
        dialog --backtitle "DLDAP - Alterar Máquina" --title "Erro" --msgbox "\nSelecione uma interface para alterar!" 8 50
        src/dldap-hosts.sh
        exit
fi

## Exibindo um menu com as opções disponíveis de alteração para interface
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

## Verificando se o usuário apertou ESC ou em Cancel
if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

## Executando a alteração de acordo com a opção selecionada
case "$op" in
        1) src/host/att-ifs.sh $host $interface description "Nova descrição: ";;
	2) src/host/att-ifs.sh $host $interface ipHostNumber "Novo IP da Interface: ";;
	3) src/host/att-ifs.sh $host $interface ipNetmaskNumber "Nova máscara da rede: ";;
	4) src/host/att-ifs.sh $host $interface ipNetworkNumber "Novo IP da rede: ";;
	5) src/host/att-ifs.sh $host $interface macAddress "Novo endereço MAC da Interface: ";;
        0) ./dldap-hosts.sh ;;
esac
