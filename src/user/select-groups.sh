#!/bin/bash
## Obtendo as informações da base
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)


## Obtendo as informações passadas como parâmetro
op=$1
user=$2
title=$3
backtitle=$4

## Gerando os respectivos filtros para as duas operações
addFilter="!(uniqueMember=uid=$user,ou=Usuarios,$base)"
delFilter="uniqueMember=uid=$user,ou=Usuarios,$base"

## Verificando qual das opções foi passada como parâmetro
if [ $op = "add" ]; then
	filter=$addFilter
	message="Não foi encontrado nenhum grupo do qual o usuário $user não é membro!"
else
	filter=$delFilter
	message="Não foi encontrado nenhum grupo do qual o usuário $user é membro!"
fi

## Buscando os grupos de acordo com a operação selecionada
groups=$(ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "ou=Grupos,$base" "(&(objectClass=posixGroup)($filter))" cn -w $password | grep cn: | cut -d" " -f2)

## Gerando a lista para o checklist a seguir
LIST=()
for linha in $(echo $groups)
do
	DESC=''
	LIST+=( $linha "$DESC" off)
done

## Verificando se foi encontrado algum grupo de acordo com o filtro aplicado
if [ ${#LIST[@]} -eq 0 ];then
	 dialog                                            \
  --backtitle "$backtitle"                 \
   --title 'Erro'                             \
   --msgbox "\n$message"  \
   8 40
        src/dldap-users.sh
        exit
fi

## Exibindo o checklist com os grupos encontrados através do filtro
grupos=$( dialog --stdout \
	--backtitle "$backtitle" \
	--title "$title" \
        --separate-output \
        --checklist '' 0 40 0 \
	"${LIST[@]}" \
	)

## Verificando se o usuário apertou ESC ou em Cancel
if [ $? -ne 0 ];then
	echo "null"
	exit 
fi

## Exibindo os grupos selecionados
echo $grupos
