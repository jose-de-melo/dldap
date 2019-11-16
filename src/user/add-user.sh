#!/bin/bash



# 
# Janela para ler o uid do novo usuário
#
uid=$( dialog --stdout                         \
   --backtitle 'DLDAP - Cadastrar Usuário'      \
   --title 'Novo Usuário'                         \
   --inputbox '\n\nUsername (uid): '  \
   13 50 )



#
# Verificando se o usuário não deixou o campo em branco. Caso tenha feito isso, a criação de um novo 
# usuário será abortada.
#
if [ -z $uid ];
then
	dialog                                            \
  --backtitle 'DLDAP - Adiconar Usuário'                 \
   --title 'Erro!'                             \
   --msgbox 'UID não pode ser vazio!'  \
   6 40
	src/dldap-users.sh
	exit
fi



#
# Verificando se o uid fornecido já existe na base de dados
#
basePass=$(cat .password)


ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "dc=jose,dc=labredes,dc=info" "(objectClass=posixAccount)" -w $basePass | grep uid: | cut -d" " -f2 > tmp.txt

while read line
do
	if [ $line = $uid ];
	then
		dialog --backtitle 'DLDAP - Adiconar Usuário' --title 'Erro!' --msgbox 'O UID fornecido já está sendo usado!' 6 40
		rm -rf tmp.txt
        	src/dldap-users.sh
		exit
	fi
done < tmp.txt

rm -rf tmp.txt




#
# Janela para ler a informação gecos do novo usuário
#
gecos=$( dialog --stdout                         \
   --backtitle 'DLDAP - Cadastrar Usuário'      \
   --title 'Novo Usuário'                         \
   --inputbox '\n\nGecos: '  \
   13 50 )


#
# Verificando se o valor lido não está vazio. Se estiver, o programa será abortado.
#
if [ -z $(echo $gecos | awk '{ print $NF}') ];
then
	dialog --backtitle 'DLDAP - Adiconar Usuário' --title 'Erro!' --msgbox 'O campo Gecos é obrigatório e não pode ser vazio!' 6 40

	src/dldap-users.sh
        exit
fi



#
# Janela para ler a senha para o novo usuário.
#
password=$( dialog --stdout                   \
   --backtitle 'DLDAP - Cadastrar Usuário'      \
   --title 'Novo Usuário'                         \
   --passwordbox '\n\nSenha: '  \
   13 50 )


#
# Verficando se o valor lido não está vazio
#
if [ -z $password ];
then
	dialog --backtitle 'DLDAP - Adiconar Usuário' --title 'Erro!' --msgbox 'A senha fornecida não é válida!' 6 40

	src/dldap-users.sh
        exit
fi





cn=$( echo $uid | tr 'A-Z' 'a-z' | sed 'y/áÁàÀãÃâÂéÉêÊíÍóÓõÕôÔúÚçÇ/aAaAaAaAeEeEiIoOoOoOuUcC/' )
sn=$(echo $gecos | awk '{ print $NF }' | tr 'A-Z' 'a-z' | sed 'y/áÁàÀãÃâÂéÉêÊíÍóÓõÕôÔúÚçÇ/aAaAaAaAeEeEiIoOoOoOuUcC/')
gecos=$(echo $gecos | sed 'y/áÁàÀãÃâÂéÉêÊíÍóÓõÕôÔúÚçÇ/aAaAaAaAeEeEiIoOoOoOuUcC/')
uidNumber=$(expr $(src/user/get-greatest-uid.sh) + 1)
date=$(expr $(date +"%s") / 86400)
password=$(python -c 'import crypt; import sys;print crypt.crypt(sys.argv[1],crypt.mksalt(crypt.METHOD_SHA512))' $password )

cat src/user/ldifs/user.ldif | sed "s/<uid>/$uid/" | sed "s/<date>/$date/" | sed "s/<cn>/$cn/" | sed "s/<sn>/$sn/" | sed "s/<id>/$uidNumber/" >> src/user/ldifs/tmp.ldif

cat src/user/ldifs/tmp.ldif | sed "12c\gecos: $gecos" | sed "13c\userPassword: {crypt}$password" >> src/user/ldifs/$uid.ldif

src/user/ldap-add-user.sh $uid

dialog --backtitle "DLDAP - Adicionar Usuário" --yesno 'Deseja inserir o usuário a um grupo já cadastrado?' 10 30 

if [ $? -eq 0 ];
then
	groups=$(src/user/select-groups.sh add $uid "Selecionar Grupo(s)" "DLDAP - Adicionar Usuário")
	
	for group in $groups
	do
		src/group/add-or-del-user-group.sh add $group $uid
	done
fi	


mv src/user/ldifs/$uid.ldif logs/ldifs





rm -rf src/user/ldifs/tmp.ldif
rm -rf awkvar.outs




dialog                                            \
  --backtitle 'DLDAP - Adiconar Usuário'                 \
   --title 'Sucesso!'                             \
   --msgbox 'Usuário adicionado com êxito!'  \
   6 40

src/dldap-users.sh
