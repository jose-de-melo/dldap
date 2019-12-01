#!/bin/bash


## Obtendo as informações da base
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Obtendo os usuários da base LDAP
groups=$(ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "$base" "(objectClass=posixAccount)" cn -w $password | grep cn: | cut -d" " -f2)

## Montando os opções do radiolist
LIST=()
first=true
DESC=''
for linha in $(echo $groups)
do
        if [ $first ];then
                LIST+=( $linha "$DESC" on)
        else
                LIST+=( $linha "$DESC" off)
        fi
done

## Exibindo o radiolist com a lista de usuários
user=$(
      dialog --stdout --cancel-label "Voltar" \
	    --backtitle 'DLDAP - Exlcuir Usuário'               \
            --radiolist 'Selecione um usuário a ser excluído' \
            0 0 0                   \
            "${LIST[@]}"  ) 


## Verificando se o usuário apertou ESC ou em Voltar
if [ $? -ne 0 ];then 
	src/dldap-users.sh
	exit
fi

## Executando a deleção do usuário e do grupo criado com o mesmo nome
src/user/remove-user.sh $user
src/user/remove-user-from-group.sh $user

## Informando ao usuário que a operação foi realizada com sucesso
dialog                                            \
  --backtitle 'DLDAP - Excluir Usuário'                 \
   --title 'Finalizado!'                             \
   --msgbox 'Exclusão realizada com sucesso!'  \
   6 40

## Voltando a tela de gerência de usuários
src/dldap-users.sh
