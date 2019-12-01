#!/bin/bash

## Obtendo as informações da base
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
pass=$(./getconfig.sh userPassword)

## Obtendo o uid do usuário passado como parâmetro
uid=$1

## Obtendo a nova senha para o usuário
password=$( dialog --stdout                   \
   --backtitle 'DLDAP - Alterar Usuário'      \
   --title 'Alterar Senha'                         \
   --passwordbox '\n\nNova senha: '  \
   13 50 )

## Verificando se o usuário apertou ESC ou em Cancel
if [ $? -ne 0 ];then
	src/dldap-users.sh
	exit
fi

## Verificando se o usuário deixou o campo em branco
if [ -z "$password" ];
then
        dialog --backtitle 'DLDAP - Alterar Usuário' --title 'Erro!' --msgbox 'Forneça uma senha válida!' 6 40
        src/dldap-users.sh
        exit
fi

## Gerando a senha criptografada em SHA512 
password=$(python -c 'import crypt; import sys;print crypt.crypt(sys.argv[1],crypt.mksalt(crypt.METHOD_SHA512))' $password )

## Montando o arquivo ldif para a alteração
cat src/user/ldifs/modify-password-user.ldif | sed "s/<base>/$base/" | sed "s/<uid>/$uid/" >> tmp
cat tmp | sed "4c\userPassword: {crypt}$password" >> $uid-replace-password.ldif

## Removendo o arquivo temporário gerado
rm -rf tmp

## Executando a alteração
ldapmodify -x -D "$userBase" -H ldap://ldap1 -f $uid-replace-password.ldif -w $pass >> /dev/null

## Gerando log para a operação
echo "$(date "+%H:%M") - MODIFY PASSWORD FROM $uid" >> logs/$(date "+%d%m%Y")-dldap.log

## Movendo o arquivo ldif gerado para o diretório de logs
mv $uid-replace-password.ldif logs/ldifs

## Informando ao usuário que a operação foi realizada com sucesso
dialog                                            \
  --backtitle 'DLDAP - Alterar Usuário'                 \
   --title 'Sucesso!'                             \
   --msgbox "A senha do usuário $uid foi atualizada!"  \
   6 40

## Retornando a tela de gerência de usuários
src/dldap-users.sh
