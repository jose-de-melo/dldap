#!/bin/bash

## Obtendo os dados da base LDAP
base=$(./getconfig.sh base)
userBase=$(./getconfig.sh user)
password=$(./getconfig.sh userPassword)

## Obtendo o nome da máquina passado como parâmetro
host=$1

## Buscando as interfaces cadastradas para o host e armazenando em um arquivo temporário
ldapsearch -LLL -x -D "$userBase" -H ldap://ldap1 -b "cn=$host,ou=Maquinas,$base" "(objectClass=ipHost)" -w $password > tmp

## Tratando os dados e gerando a lista para radiolist a seguir
ifs=$(cat tmp | grep "dn: cn=" | cut -d" " -f2 | cut -d"," -f1 | cut -d"=" -f2)
LIST=()
DESC=''
for int in $(echo $ifs)
do
        LIST+=( $int "$DESC" off)
done

## Verificando se o host não possui interfaces cadastradas
if [ ${#LIST[@]} -eq 0 ];
then
        dialog                                            \
  --backtitle 'DLDAP - Alterar Máquina'                 \
   --title 'INFO'                             \
   --msgbox "\nA máquina $host não possui nenhuma interface cadastrada! \n"  \
   8 50
        src/dldap-hosts.sh
        rm -rf tmp
        exit
fi

## Removendo o arquivo temporário
rm -rf tmp

## Exibindo o radiolist com as interfaces do host
interface=$( dialog --stdout --cancel-label "Cancelar" \
        --backtitle "DLDAP - Alterar Máquina" \
        --title "Remover interface" \
        --radiolist 'Selecione uma interface' 0 40 0 \
        "${LIST[@]}" \
        )

## Verificando se o usuário apertou ESC ou em Cancelar
if [ $? -ne 0 ]; then
        src/dldap-hosts.sh
        exit
fi

## Solicitando confirmação para excluir interface
dialog --backtitle "DLDAP - Alterar Máquina: $host" --title 'Excluir Interface' --yesno "Confirma a exclusão da interface $interface da máquina $host ?" 7 45

## Executando deleção caso o usuário tenha confirmado a exclusão
if [ $? -eq 0 ];then
        src/host/del-if.sh $host $interface
	## Informando ao usuário que operação foi realizada
        dialog                                            \
  --backtitle 'DLDAP - Alterar Máquina'                 \
   --title 'INFO'                             \
   --msgbox "A interface $interface da máquina $host foi removida!"  \
   6 40
fi

## Retornando a tela de gerência de máquinas
src/dldap-hosts.sh
