#!/bin/bash

#nome=$( dialog --backtitle 'DLDAP - Consultar Usuário' --stdout --inputbox 'Nome do usuário:' 0 0 )

[ $? -ne 0 ] && exit

resposta=$(
      dialog --stdout --backtitle 'DLDAP - Consultar Usuário'               \
             --menu 'Escolha um usuário para consultar:' \
            0 0 0                   \
	    $(./src/user/make-list-users.sh) \
            'Voltar' ''         )


if [ $? -ne 0 ]; then
	src/dldap-users.sh
	exit
fi

if [ $resposta = 'Voltar' ];then
	./src/dldap-users.sh
else
	src/user/show-user.sh $resposta
fi
