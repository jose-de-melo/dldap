#!/bin/bash

password=$(cat .password)
host=$1

cn=$( dialog --stdout                         \
   --backtitle 'DLDAP - Alterar Máquina'      \
   --title 'Adicionar Interface'                         \
   --inputbox '\n\nNome da interface (cn): '  \
   13 50 )


if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

if [ -z "$cn" ];then
         dialog --backtitle 'DLDAP - Alterar Máquina' --title 'Erro!' --msgbox 'O nome da interface não pode ser nulo!' 6 40
        src/dldap-hosts.sh
        exit
fi

cn=$(src/adjust-text.sh $cn double)

ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "ou=Maquinas,dc=jose,dc=labredes,dc=info" "(objectClass=ipHost)" -w $password | grep "dn: cn=$cn,cn=$host"

if [ $? -eq 0 ]; then
                dialog --backtitle 'DLDAP - Alterar Máquina' --title 'Erro!' --msgbox "A máquina $host já possui uma interface com esse nome!" 6 40
		src/dldap-hosts.sh
		exit
fi

desc=$(dialog --stdout                         \
   --backtitle 'DLDAP - Alterar Máquina'      \
   --title 'Adicionar Interface'                         \
   --inputbox '\n\nDescrição : '  \
   13 50 )


if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

if [ -z "$desc" ];then
         dialog --backtitle 'DLDAP - Alterar Máquina' --title 'Erro!' --msgbox 'A descrição da interface não pode ser nula!' 6 40
        src/dldap-hosts.sh
        exit
fi

desc=$(src/adjust-text.sh "$desc" noaccent)

ip=$(dialog --stdout                         \
   --backtitle 'DLDAP - Alterar Máquina'      \
   --title 'Adicionar Interface'                         \
   --inputbox '\n\nIP da interface: '  \
   13 50 )


if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

if [ -z "$ip" ];then
         dialog --backtitle 'DLDAP - Alterar Máquina' --title 'Erro!' --msgbox 'O IP não pode estar vazio!' 6 40
	src/dldap-hosts.sh
        exit
fi

mask=$(dialog --stdout                         \
   --backtitle 'DLDAP - Alterar Máquina'      \
   --title 'Adicionar Interface'                         \
   --inputbox '\n\nMáscara: '  \
   13 50 )                                                                                              

if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

if [ -z "$mask" ];then
         dialog --backtitle 'DLDAP - Alterar Máquina' --title 'Erro!' --msgbox 'A máscara do IP da interface não pode estar vazia!' 6 40
        src/dldap-hosts.sh
        exit
fi

ipNet=$(dialog --stdout                         \
   --backtitle 'DLDAP - Alterar Máquina'      \
   --title 'Adicionar Interface'                         \
   --inputbox '\n\nIP da subrede: '  \
   13 50 )

if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

if [ -z "$ipNet" ];then
         dialog --backtitle 'DLDAP - Alterar Máquina' --title 'Erro!' --msgbox "O IP de subrede inválido!" 6 40
        src/dldap-hosts.sh
        exit
fi

mac=$(dialog --stdout                         \
   --backtitle 'DLDAP - Alterar Máquina'      \
   --title 'Adicionar Interface'                         \
   --inputbox '\n\nEndereço MAC: '  \
   13 50 )

if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

if [ -z "$mac" ];then
         dialog --backtitle 'DLDAP - Alterar Máquina' --title 'Erro!' --msgbox 'Endereço MAC inválido!' 6 40
        src/dldap-hosts.sh
        exit
fi

cat src/host/ldifs/interface.ldif | sed "s/<cn>/$cn/" | sed "s/<host>/$host/" | sed "s/<ip>/$ip/" | sed "s/<mask>/$mask/" | sed "s/<ipNet>/$ipNet/" | sed "s/<mac>/$mac/" | sed "6c\description: $desc" > if-$cn-$host.ldif

ldapadd -x -D 'cn=admin,dc=jose,dc=labredes,dc=info' -H ldap://ldap1 -f if-$cn-$host.ldif -w $password >> logs/modify-hosts.log

echo "\nADD INTERFACE $cn TO HOST $host" >> logs/modify-hosts.log
mv if-$cn-$host.ldif logs/ldifs

dialog --backtitle "DLDAP - Alterar Máquina" --title "INFO" --msgbox "\nInterface $cn adicionada ao host $host!" 6 50

src/dldap-hosts.sh
