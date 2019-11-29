#!/bin/bash
password=$(cat .password)
cn=$( dialog --stdout                         \
   --backtitle 'DLDAP - Adicionar Máquina'      \
   --title 'Nova Máquina'                         \
   --inputbox '\n\nNome da máquina (cn): '  \
   13 50 )


if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

if [ -z "$cn" ];then
	 dialog --backtitle 'DLDAP - Adicionar Usuário' --title 'Erro!' --msgbox 'O nome da máquina não pode ser nulo!' 6 40
        src/dldap-hosts.sh
        exit
fi

ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "ou=Maquinas,dc=jose,dc=labredes,dc=info" "(objectClass=nisNetGroup)" -w $password | grep "dn: cn=$cn"

if [ $? -eq 0 ]; then
                dialog --backtitle 'DLDAP - Adicionar Máquina' --title 'Erro!' --msgbox 'O nome fornecido já está sendo utilizado!' 6 40
                src/dldap-hosts.sh
                exit
fi

desc=$( dialog --stdout                         \
   --backtitle 'DLDAP - Adicionar Máquina'      \
   --title 'Nova Máquina'                         \
   --inputbox '\n\nDescrição da Máquina: '  \
   13 50 )


if [ $? -ne 0 ];then
        src/dldap-hosts.sh
        exit
fi

if [ -z "$cn" ];then
         dialog --backtitle 'DLDAP - Adicionar Máquina' --title 'Erro!' --msgbox 'A descrição não pode ser vazia!' 6 40
        src/dldap-hosts.sh
        exit
fi

cn=$( echo $cn | tr 'A-Z' 'a-z' | sed 'y/áÁàÀãÃâÂéÉêÊíÍóÓõÕôÔúÚçÇ/aAaAaAaAeEeEiIoOoOoOuUcC/' )
desc=$( echo $desc | sed 'y/áÁàÀãÃâÂéÉêÊíÍóÓõÕôÔúÚçÇ/aAaAaAaAeEeEiIoOoOoOuUcC/' )

cat src/host/ldifs/host.ldif | sed "s/<cn>/$cn/" | sed "4c\description: $desc" > add-host-$cn.ldif

ldapadd -x -D 'cn=admin,dc=jose,dc=labredes,dc=info' -H ldap://ldap1 -f add-host-$cn.ldif -w $password >> logs/add-host.log

echo "$(date "+%H:%M") - ADD HOST $cn" >> logs/$(date "+%d%m%Y")-dldap.log

mv add-host-$cn.ldif logs/ldifs

dialog --backtitle "DLDAP - Cadastrar Máquina" --title "INFO" --msgbox "\nMáquina cadastrada com sucesso!\n\nPara cadastrar interfaces de rede para a máquina, selecione 'Alterar Máquina' e escolha a máquina que acabou de cadastrar." 10 70

src/dldap-hosts.sh
