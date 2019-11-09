#!/bin/bash

user=$1
password=$(cat .password)

dialog --backtitle "DLDAP - Excluir Usuário: $user" --title 'Confirmar Exclusão' --yesno "Confirmar exclusão do usuário $user?\n\nATENÇÃO: O usuário será excluído por completo, incluindo o grupo de mesmo nome" 10 60

if [ $? = 0 ]; then
        ldapdelete -x -D 'cn=admin,dc=jose,dc=labredes,dc=info' -H ldap://ldap1 "uid=$user,ou=Usuarios,dc=jose,dc=labredes,dc=info" -w $password >> /dev/null
	ldapdelete -x -D 'cn=admin,dc=jose,dc=labredes,dc=info' -H ldap://ldap1 "cn=$user,ou=Grupos,dc=jose,dc=labredes,dc=info" -w $password >> /dev/null
	dialog                                            \
  --backtitle 'DLDAP - Excluir Usuário'			\
   --title 'Finalizado!'                             \
   --msgbox 'Exclusão realizada com sucesso!'  \
   6 40
fi

src/dldap-users.sh
