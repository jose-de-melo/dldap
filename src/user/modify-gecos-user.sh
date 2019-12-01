#/bin/bash

## Obtendo as informações da base
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Obtendo o uid do usuário passado como parâmetro
uid=$1

## Obtendo o novo valor de gecos para o usuário
gecos=$( dialog --stdout                         \
   --backtitle 'DLDAP - Alterar Usuário'      \
   --title "Alterar Gecos do usuário: $uid"                         \
   --inputbox '\n\nNovo valor: '  \
   13 50 )

## Verificando se o usuário apertou ESC ou em Cancel
if [ $? -ne 0 ]; then
	src/dldap-users.sh
	exit
fi

## Verificando se o usuário deixou o campo em branco
if [ -z "$gecos" ];
then
	dialog --backtitle 'DLDAP - Alterar Usuário' --title 'Erro!' --msgbox 'O novo valor não pode ser vazio!' 6 40
        src/dldap-users.sh
        exit
fi

## Ajustando o texto lido, removendo possíveis acentos e caracteres especiais
gecos=$(src/adjust-text.sh "$gecos" noaccent)

## Montando o arquivo ldif para a alteração
cat src/user/ldifs/modify-gecos-user.ldif | sed "s/<base>/$base/" | sed "s/<uid>/$uid/" | sed "s/<gecos>/$gecos/" >> $uid-replace-gecos.ldif

## Executando a alteração
ldapmodify -x -D "$userBase" -H ldap://ldap1 -f $uid-replace-gecos.ldif -w $password >> logs/modify-users.log

## Gerando log para a operação realizada
echo "$(date "+%H:%M") - MODIFY GECOS FROM $uid TO $gecos" >> logs/$(date "+%d%m%Y")-dldap.log

## Movendo o arquivo ldif gerado para o diretório de logs
mv $uid-replace-gecos.ldif logs/ldifs

## Informando ao usuário que a operação foi finalizada
dialog                                            \
  --backtitle 'DLDAP - Alterar Usuário'                 \
   --title 'Sucesso!'                             \
   --msgbox "O campo Gecos do usuário $uid foi alterado."  \
   6 40

## Retorando a tela de gerência de usuários
src/dldap-users.sh
