#!/bin/bash

## Obtendo as informações da base
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Obtendo o nome da nova máquina
cn=$( dialog --stdout                         \
   --backtitle 'DLDAP - Adicionar Máquina'      \
   --title 'Nova Máquina'                         \
   --inputbox '\n\nNome da máquina (cn): '  \
   13 50 )

## Verificando se o usuário apertou ESC ou em Cancel
if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

## Verificando se o usuário não deixou o campo em branco
if [ -z "$cn" ];then
	 dialog --backtitle 'DLDAP - Adicionar Usuário' --title 'Erro!' --msgbox 'O nome da máquina não pode ser nulo!' 6 40
        src/dldap-hosts.sh
        exit
fi

## Verificando se o nome fornecido já não está sendo usado na base
ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "ou=Maquinas,$base" "(objectClass=nisNetGroup)" -w $password | grep "dn: cn=$cn"

if [ $? -eq 0 ]; then
                dialog --backtitle 'DLDAP - Adicionar Máquina' --title 'Erro!' --msgbox 'O nome fornecido já está sendo utilizado!' 6 40
                src/dldap-hosts.sh
                exit
fi

## Obtendo a descrição da máquina
desc=$( dialog --stdout                         \
   --backtitle 'DLDAP - Adicionar Máquina'      \
   --title 'Nova Máquina'                         \
   --inputbox '\n\nDescrição da Máquina: '  \
   13 50 )

## Verificando se o usuário apertou ESC ou em Cancel
if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

## Verificando se o usuário não deixou o campo em branco
if [ -z "$cn" ];then
         dialog --backtitle 'DLDAP - Adicionar Máquina' --title 'Erro!' --msgbox 'A descrição não pode ser vazia!' 6 40
        src/dldap-hosts.sh
        exit
fi

## Ajustando as informações obtidas. Removendo acentos e letras maiscúlas da cn e removendo
## apenas os acentos da descrição
cn=$(src/adjust-text.sh $cn double)
desc=$(src/adjust-text.sh "$desc" noaccent)

## Montando o arquivo ldif para adicionar uma nova máquina
cat src/host/ldifs/host.ldif | sed "s/<base>/$base/" | sed "s/<cn>/$cn/" | sed "4c\description: $desc" > add-host-$cn.ldif

## Executando a operação
ldapadd -x -D "$userBase" -H ldap://ldap1 -f add-host-$cn.ldif -w $password > /dev/null

## Gerando log para operação
echo "$(date "+%H:%M") - ADD HOST $cn" >> logs/$(date "+%d%m%Y")-dldap.log

## Movendo o arquivo ldif gerado
mv add-host-$cn.ldif logs/ldifs

## Confirmando que a operação foi realizada
dialog --backtitle "DLDAP - Cadastrar Máquina" --title "INFO" --msgbox "\nMáquina cadastrada com sucesso!\n\nPara cadastrar interfaces de rede para a máquina, selecione 'Alterar Máquina' e escolha a máquina que acabou de cadastrar." 10 70

## Retornando a tela de gerência de hosts
src/dldap-hosts.sh
