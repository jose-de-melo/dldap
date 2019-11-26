#/bin/bash


uid=$1

gecos=$( dialog --stdout                         \
   --backtitle 'DLDAP - Alterar Usuário'      \
   --title "Alterar Gecos do usuário: $uid"                         \
   --inputbox '\n\nNovo valor: '  \
   13 50 )

if [ $? -ne 0 ]; then
	src/dldap-users.sh
	exit
fi



if [ -z "$gecos" ];
then
	dialog --backtitle 'DLDAP - Alterar Usuário' --title 'Erro!' --msgbox 'O novo valor não pode ser vazio!' 6 40
        src/dldap-users.sh
        exit
fi


password=$(cat .password)


gecos=$(echo $gecos | sed 'y/áÁàÀãÃâÂéÉêÊíÍóÓõÕôÔúÚçÇ/aAaAaAaAeEeEiIoOoOoOuUcC/')

cat src/user/ldifs/modify-gecos-user.ldif | sed "s/<uid>/$uid/" | sed "s/<gecos>/$gecos/" >> $uid-replace-gecos.ldif


ldapmodify -x -D 'cn=admin,dc=jose,dc=labredes,dc=info' -H ldap://ldap1 -f $uid-replace-gecos.ldif -w $password >> logs/modify-users.log

echo -e "MODIFY GECOS FROM $uid TO $gecos \n" >> logs/modify-users.log

mv $uid-replace-gecos.ldif logs/ldifs


dialog                                            \
  --backtitle 'DLDAP - Alterar Usuário'                 \
   --title 'Sucesso!'                             \
   --msgbox "O campo Gecos do usuário $uid foi alterado."  \
   6 40

src/dldap-users.sh
