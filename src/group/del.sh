#/bin/bash

#############################
## Obtendo as informações da base
#############################
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

######################################
## Obtendo os grupos cadastrados na base LDAP
######################################
groups=$(ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "$base" "(objectClass=posixGroup)" cn -w $password | grep cn: | cut -d" " -f2)

################################
## Montando as opções do radiolist seguinte
################################
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

##################################
## Exibindo o radiolist com os grupos cadastrados no LDAP
##################################
group=$( dialog --stdout \
        --backtitle "DLDAP - Excluir Grupo" \
        --title "Excluir Grupo" \
        --radiolist 'Selecione um grupo:' 0 40 0 \
        "${LIST[@]}" \
        )

################################
## Verificando se o usuário apertou ESC ou em Cancelar
################################
if [ $? -ne 0 ]; then
	src/dldap-groups.sh
	exit
fi

###############################
## Solicitando confirmação para excluir o grupo
###############################
dialog --backtitle "DLDAP - Excluir Grupo" --title 'Confirmar Exclusão' --yesno "\n\nConfirmar exclusão do grupo $group?" 10 40

###############################
## Verificando se o usuário confirmou ou cancelou a operação
###############################
if [ $? = 0 ]; then
	##############
	## Executando a deleção
	##############
	ldapdelete -x -D "$userBase" -H ldap://ldap1 "cn=$group,ou=Grupos,dc=jose,dc=labredes,dc=info" -w $password > /dev/null
	dialog --backtitle "DLDAP - Excluir Usuário" --title "Exclusão Realizada" --ok-label "Voltar" --msgbox "\nO grupo $group foi excluído!" 8 40
	###############
	## Gerando log para a operação
	################
	echo "$(date "+%H:%M") - DELETE GROUP $group" >> logs/$(date "+%d%m%Y")-dldap.log
	##################
	## Voltando a tela anterior
	##################
	src/dldap-groups.sh
else
	dialog --backtitle "DLDAP - Excluir Usuário" --title "Exlcusão cancelada" --ok-label "Voltar" --msgbox "\nO grupo $group não será excluído!" 8 40
	src/dldap-groups.sh
fi
