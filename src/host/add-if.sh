#!/bin/bash

## Obtendo os dados da base LDAP
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Obtendo a máquina passada como parâmetro
host=$1


## Obtendo o nome da nova interface
cn=$( dialog --stdout                         \
   --backtitle 'DLDAP - Alterar Máquina'      \
   --title 'Adicionar Interface'                         \
   --inputbox '\n\nNome da interface (cn): '  \
   13 50 )

## Verificando se o usuário apertou ESC ou em Cancel
if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

## Verificando se o usuário não deixou o campo
if [ -z "$cn" ];then
         dialog --backtitle 'DLDAP - Alterar Máquina' --title 'Erro!' --msgbox 'O nome da interface não pode ser nulo!' 6 40
        src/dldap-hosts.sh
        exit
fi

## Removendo acentos e letras maiscúlas
cn=$(src/adjust-text.sh $cn double)

## Verificando se o nome fornecido já está sendo usado por uma interface do host
ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "ou=Maquinas,$base" "(objectClass=ipHost)" -w $password | grep "dn: cn=$cn,cn=$host"
if [ $? -eq 0 ]; then
                dialog --backtitle 'DLDAP - Alterar Máquina' --title 'Erro!' --msgbox "A máquina $host já possui uma interface com esse nome!" 6 40
		src/dldap-hosts.sh
		exit
fi

## Obtendo a descrição da interface
desc=$(dialog --stdout                         \
   --backtitle 'DLDAP - Alterar Máquina'      \
   --title 'Adicionar Interface'                         \
   --inputbox '\n\nDescrição : '  \
   13 50 )

## Verificando se o usuário apertou ESC ou em Cancel
if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

## Verificando se o usuário não deixou o campo vazio
if [ -z "$desc" ];then
         dialog --backtitle 'DLDAP - Alterar Máquina' --title 'Erro!' --msgbox 'A descrição da interface não pode ser nula!' 6 40
        src/dldap-hosts.sh
        exit
fi

## Ajustando o texto obtido, removendo acentos
desc=$(src/adjust-text.sh "$desc" noaccent)

## Obtendo o ip da nova interface
ip=$(dialog --stdout                         \
   --backtitle 'DLDAP - Alterar Máquina'      \
   --title 'Adicionar Interface'                         \
   --inputbox '\n\nIP da interface: '  \
   13 50 )

## Verificando se o usuário apertou Esc ou em Cancel
if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

## Verificando se o usuário não deixou o campo vazio
if [ -z "$ip" ];then
         dialog --backtitle 'DLDAP - Alterar Máquina' --title 'Erro!' --msgbox 'O IP não pode estar vazio!' 6 40
	src/dldap-hosts.sh
        exit
fi

## Obtendo a máscara do IP da interface
mask=$(dialog --stdout                         \
   --backtitle 'DLDAP - Alterar Máquina'      \
   --title 'Adicionar Interface'                         \
   --inputbox '\n\nMáscara: '  \
   13 50 )                                                                                              

## Verificando se o usuário não apertou ESC ou em Cancel
if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

## Verificando se o usuário não deixou o campo vazio
if [ -z "$mask" ];then
         dialog --backtitle 'DLDAP - Alterar Máquina' --title 'Erro!' --msgbox 'A máscara do IP da interface não pode estar vazia!' 6 40
        src/dldap-hosts.sh
        exit
fi

## Obtendo o IP da rede da qual a interface faz parte
ipNet=$(dialog --stdout                         \
   --backtitle 'DLDAP - Alterar Máquina'      \
   --title 'Adicionar Interface'                         \
   --inputbox '\n\nIP da subrede: '  \
   13 50 )

## Verificando se o usuário apertou a tecla ESC ou em Cancel
if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

## Verificando se o usuário não deixou o campo vazio
if [ -z "$ipNet" ];then
         dialog --backtitle 'DLDAP - Alterar Máquina' --title 'Erro!' --msgbox "O IP de subrede inválido!" 6 40
        src/dldap-hosts.sh
        exit
fi

## Obtendo o endereço MAC da interface
mac=$(dialog --stdout                         \
   --backtitle 'DLDAP - Alterar Máquina'      \
   --title 'Adicionar Interface'                         \
   --inputbox '\n\nEndereço MAC: '  \
   13 50 )

## Verificando se o usuário apertou ESC ou em Cancel
if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

## Verificando se o usuário não deixou o campo vazio
if [ -z "$mac" ];then
         dialog --backtitle 'DLDAP - Alterar Máquina' --title 'Erro!' --msgbox 'Endereço MAC inválido!' 6 40
        src/dldap-hosts.sh
        exit
fi

## Montando o arquivo ldif para adicionar a nova interface
cat src/host/ldifs/interface.ldif | sed "s/<base>/$base/" | sed "s/<cn>/$cn/" | sed "s/<host>/$host/" | sed "s/<ip>/$ip/" | sed "s/<mask>/$mask/" | sed "s/<ipNet>/$ipNet/" | sed "s/<mac>/$mac/" | sed "6c\description: $desc" > if-$cn-$host.ldif

## Executando a adição da nova interface
ldapadd -x -D "$userBase" -H ldap://ldap1 -f if-$cn-$host.ldif -w $password > /dev/null

## Gerando o log para a operação realizada
echo "$(date "+%H:%M") - ADD INTERFACE $cn TO HOST $host" >> logs/$(date "+%d%m%Y")-dldap.log
mv if-$cn-$host.ldif logs/ldifs

## Informando ao usuário que operação foi realizada
dialog --backtitle "DLDAP - Alterar Máquina" --title "INFO" --msgbox "\nInterface $cn adicionada ao host $host!" 6 50

## Retornando a tela de gerência de hosts
src/dldap-hosts.sh
