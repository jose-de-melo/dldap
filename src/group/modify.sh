#!/bin/bash

## Obtendo as informações da base
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Obtendo os grupos cadastrados na base
groups=$(ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "$base" "(objectClass=posixGroup)" cn -w $password | grep cn: | cut -d" " -f2)

## Gerando a lista com as opções do radiolist a seguir
LIST=()
first=true
DESC=''
for linha in $(echo $groups)
do
        if [ $first ];then
                LIST+=( $linha "$DESC" on)
		first=false
        else
                LIST+=( $linha "$DESC" off)
        fi
done

## Exibindo o radiolist com os grupos cadastrados na base
group=$( dialog --stdout --cancel-label "Voltar" \
        --backtitle "DLDAP - Alterar Grupo" \
        --title "Alterar Grupo" \
        --radiolist 'Selecione um grupo:' 0 40 0 \
        "${LIST[@]}" \
        )

## Verificando se o usuário apertou ESC ou em Voltar
if [ $? -ne 0 ];then
	src/dldap-groups.sh
	exit
fi

## Obtendo a operação a informação do grupo que o usuário deseja alterar
resposta=$(
      dialog --stdout --cancel-label "Voltar"               \
             --backtitle "DLDAP - Alterar Grupo"      \
             --title "Alterar Grupo: $group"  \
             --menu 'Escolha um atributo para editar:' \
            0 0 0                   \
            1 'Alterar Descrição'     \
            2 'Usuários do Grupo'        \
            0 'Cancelar'                )

## Verificando se o usuário apertou ESC ou em Voltar
if [ $? -ne 0 ]; then
        src/dldap-groups.sh
        exit
fi

## Direcionando para a tela de acordo com a opção escolhida
case "$resposta" in
         1) src/group/modify-description.sh $group ;;
         2) src/group/manage-users.sh $group ;;
         0) src/dldap-users.sh ;;
esac
