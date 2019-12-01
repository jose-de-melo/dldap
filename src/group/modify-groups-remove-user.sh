#!/bin/bash

## Obtendo as informações da base
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Obtendo o grupo passado como parâmetro
group=$1

## Gerando a lista de usuários do grupo 
list=$(ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "ou=Grupos,$base" "(&(objectClass=posixGroup)(cn=$group))" uniqueMember -w $password | grep uniqueMember | cut -d" " -f2 | cut -d"," -f1 | cut -d"=" -f2)

## Formatando a lista para formato de opções de um radiolist
LIST=()
first=0
DESC=''
for linha in $(echo $list)
do
	if [ $first -eq 0 ];then
        	LIST+=( $linha "$DESC" on)
                first=1
        else
                LIST+=( $linha "$DESC" off)
	fi
done


## Verificando se o grupo possui apenas um membro, nesse caso o mesmo não poderá ser removido.
if [ ${#LIST[@]} -eq 3 ];
then
        dialog                                            \
  --backtitle 'DLDAP - Alterar Grupo'                 \
   --title 'Erro'                             \
   --msgbox "\nO grupo $group possui apenas um membro, nesse caso, a remoção do mesmo não pode ser realizada para não afetar a integridade do objeto !\n"  \
   10 50
        src/dldap-groups.sh
        exit
fi

## Exibindo o radiolist com os membros do grupo selecionado
user=$( dialog --stdout \
        --backtitle "DLDAP - Alterar Grupo" \
        --title "Remover Membro : $group" \
        --radiolist '' 10 50 0 \
        "${LIST[@]}" \
        )

## Verificando se o usuário apertou ESC ou cancelou a operação
if [ $? -ne 0 ]; then
        src/dldap-groups.sh
        exit
fi

## Executando o script de deleção de usuário 
src/group/add-or-del-user-group.sh delete $group $user

## Informando ao usuário que a operação foi realizada com sucesso
dialog                                            \
  --backtitle 'DLDAP - Alterar Grupo'                 \
   --title 'Sucesso!'                             \
   --msgbox "\nO usuário $user foi removido do grupo $group !"  \
   8 40

## Voltando a tela de gerência de grupos
src/dldap-groups.sh
