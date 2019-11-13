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
	echo "UID não pode ser vazio!"
	exit 0
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
		echo "O uid fornecido já está cadastrado na base de dados!"
		rm -rf tmp.txt
		exit
		break
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
        echo "O campo Gecos não pode ser vazio!"
        exit 0
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
	echo "Forneça uma senha válida!"
	exit 0
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

mv src/user/ldifs/$uid.ldif logs/ldifs





rm -rf src/user/ldifs/tmp.ldif
rm -rf awkvar.outs




dialog                                            \
  --backtitle 'DLDAP - Adiconar Usuário'                 \
   --title 'Sucesso!'                             \
   --msgbox 'Usuário adicionado com êxito!'  \
   6 40

src/dldap-users.sh
