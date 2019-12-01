#!/bin/bash

## Obtendo os dados da base LDAP
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Listando todas os hosts cadastrados na base
hosts=$(ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "ou=Maquinas,$base" "objectClass=nisNetGroup" -w $password | grep cn: | cut -d" " -f2)

## Gerando a lista para o radiolist a seguir
LIST=()
DESC=''
for h in $(echo $hosts)
do
        LIST+=( $h "$DESC" off)
done

## Exibindo radiolist com os hosts cadastrados na base LDAP
host=$( dialog --stdout \
        --backtitle "DLDAP - Gerenciamento de Máquinas" \
        --title "Excluir Máquina" \
        --radiolist 'Selecione uma máquina para excluir:' 0 40 0 \
        "${LIST[@]}" \
       )

## Verificando se o usuário apertou ESC ou em Cancel
if [ $? -ne 0 ]; then
        src/dldap-hosts.sh
        exit
fi

## Solicitando confirmação ao usuário
dialog --backtitle "DLDAP - Excluir Máquina: $host" --title 'Confirmar Exclusão' --yesno "Confirma a exclusão da máquina $host?\n\nATENÇÃO: Ao apagar a máquina, todos as interfaces cadastradas para a mesma também serão removidas da base." 10 60

## Verificando se o usuário confirmou a operação
if [ $? -eq 0 ];then
	## Executando a deleção
	src/host/remove-host.sh $host
	## Informando ao usuário que a operação foi concluída
	dialog                                            \
  --backtitle 'DLDAP - Excluir Máquina'                 \
   --title 'INFO'                             \
   --msgbox "A máquina $host foi removida!"  \
   6 40
fi

## Voltando a tela de gerência de hosts
src/dldap-hosts.sh
