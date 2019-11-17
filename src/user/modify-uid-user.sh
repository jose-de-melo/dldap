#/bin/bash


old_uid=$1

#
# Janela para ler o uid do novo usuário
#
new_uid=$( dialog --stdout                         \
   --backtitle 'DLDAP - Alterar Usuário'      \
   --title "Alterar UID do usuário: $old_uid"                         \
   --inputbox '\n\nNovo UID: '  \
   13 50 )

[ $? -ne 0 ] && src/dldap-users.sh && exit

#
# Verificando se o usuário não deixou o campo em branco. Caso tenha feito isso, a criação de um novo
# usuário será abortada.
#
if [ -z $new_uid ];
then
	dialog --backtitle 'DLDAP - Alterar Usuário' --title 'Erro!' --msgbox 'UID não pode ser vazio!' 6 40
        src/dldap-users.sh
        exit
fi

#
# Verificando se o uid fornecido já existe na base de dados
#
password=$(cat .password)

ldapsearch -LLL -x -D "cn=admin,dc=jose,dc=labredes,dc=info" -H ldap://ldap1 -b "dc=jose,dc=labredes,dc=info" "(&(objectClass=posixAccount)(uid=$new_uid))" -w $password | grep uid:

if [ $? -eq 0 ];
then
	dialog --backtitle 'DLDAP - Consultar Usuário' --title 'Erro!' --msgbox 'O UID fornecido já está sendo usado!' 6 40
        src/dldap-users.sh
        exit
fi

cat src/user/ldifs/modify-uid-user.ldif | sed "s/<uid>/$old_uid/" | sed "s/<new_uid>/$new_uid/" >> $new_uid.ldif


ldapmodify -x -D 'cn=admin,dc=jose,dc=labredes,dc=info' -H ldap://ldap1 -f $new_uid.ldif -w $password >> logs/modify-users.log

echo "MODIFY UID: $old_uid TO $new_uid" >> logs/modify-users.log

mv $new_uid.ldif logs/ldifs











