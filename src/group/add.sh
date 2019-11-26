#!/bin/bash


password=$(cat .password)

cn=$( dialog --stdout                         \
   --backtitle 'DLDAP - Adicionar Grupo'      \
   --title 'Novo Grupo:'                         \
   --inputbox '\n\nNome (cn): '  \
   13 50 )

if [ $? -ne 0 ]; then
	src/dldap-groups.sh
	exit
fi

if [ -z "$cn" ] ;
then
	src/message.sh "DLDAP - Adicionar Grupo" "Erro" "O nome do grupo não pode ser nulo!"
	src/dldap-groups.sh
	exit
fi

ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "dc=jose,dc=labredes,dc=info" "(objectClass=posixGroup)" -w $password | grep "cn: $cn" > /dev/null

if [ $? -eq 0 ] ;
then
	src/message.sh "DLDAP - Adicionar Grupo" "Erro" "O nome fornecido já está sendo utilizado na base!"	
	src/dldap-groups.sh
	exit
fi


desc=$( dialog --stdout                         \
   --backtitle 'DLDAP - Adicionar Grupo'      \
   --title 'Novo Grupo:'                         \
   --inputbox '\n\nDescrição do grupo: '  \
   13 50 )

if [ $? -ne 0 ];then
	src/dldap-groups.sh
	exit
fi

if [ -z "$desc" ] ;
then
        src/message.sh "DLDAP - Adicionar Grupo" "Erro" "A descrição do grupo não pode ser vazia!"
        src/dldap-groups.sh
        exit
fi

users=$(ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "dc=jose,dc=labredes,dc=info" "(objectClass=posixAccount)" uid -w $password | grep uid: | cut -d" " -f2)


LIST=()

for user in $(echo $users)
do
        DESC=''
        LIST+=( $user "$DESC" off)
done

users=$( dialog --stdout \
        --backtitle "DLDAP - Adicionar Grupo" \
        --title "Selecionar usuários" \
        --separate-output \
        --checklist 'Selecione no mínimo um usuário criar o grupo:' 0 40 0 \
        "${LIST[@]}" \
        )

if [ $? -ne 0 ];then
	src/dldap-groups.sh
	exit
fi

if [ -z "$users" ];
then
	src/message.sh "DLDAP - Adicionar Grupo" "Erro" "Selecione ao menos um usuário ao criar um novo grupo!"
        src/dldap-groups.sh
        exit
fi


gid=$(expr $(src/group/get-greatest-gid.sh) + 1)

cat src/group/ldifs/add-group.ldif | sed "s/<cn>/$cn/" | sed "s/<desc>/$desc/" | sed "s/<gid>/$gid/" >> $cn.ldif


for user in $users
do
	echo "uniqueMember: uid=$user,ou=Usuarios,dc=jose,dc=labredes,dc=info" >> $cn.ldif
done

echo "" >> $cn.ldif

ldapadd -x -D 'cn=admin,dc=jose,dc=labredes,dc=info' -H ldap://ldap1 -f $cn.ldif -w $password >> logs/groupadd.log


src/message.sh "DLDAP - Adicionar Grupo" "Sucesso" "Grupo adicionado com sucesso!"



echo "ADD GROUP $cn\n" >> logs/groupadd.log
mv $cn.ldif logs/ldifs

src/dldap-groups.sh
