#!/bin/bash

pass=$(cat .password)
uid=$1





password=$( dialog --stdout                   \
   --backtitle 'DLDAP - Alterar Usuário'      \
   --title 'Alterar Senha'                         \
   --passwordbox '\n\nNova senha: '  \
   13 50 )


[ $? -ne 0 ] && src/dldap-users.sh && exit



if [ -z password ];
then
        dialog --backtitle 'DLDAP - Alterar Usuário' --title 'Erro!' --msgbox 'Forneça uma senha válida!' 6 40
        src/dldap-users.sh
        exit
fi

password=$(python -c 'import crypt; import sys;print crypt.crypt(sys.argv[1],crypt.mksalt(crypt.METHOD_SHA512))' $password )


cat src/user/ldifs/modify-password-user.ldif | sed "s/<uid>/$uid/" >> tmp
cat tmp | sed "4c\userPassword: {crypt}$password" >> $uid-replace-password.ldif

rm -rf tmp

ldapmodify -x -D 'cn=admin,dc=jose,dc=labredes,dc=info' -H ldap://ldap1 -f $uid-replace-password.ldif -w $pass >> logs/modify-users.log

echo -e "MODIFY PASSWORD FROM $uid \n" >> logs/modify-users.log

mv $uid-replace-password.ldif logs/ldifs

dialog                                            \
  --backtitle 'DLDAP - Alterar Usuário'                 \
   --title 'Sucesso!'                             \
   --msgbox "A senha do usuário $uid foi atualizada!"  \
   6 40

src/dldap-users.sh
