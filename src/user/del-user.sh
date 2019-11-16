#!/bin/bash

[ $? -ne 0 ] && exit

resposta=$(
      dialog --stdout --backtitle 'DLDAP - Exlcuir Usuário'               \
            --menu 'Selecione um usuário a ser excluído' \
            0 0 0                   \
            $(./src/user/make-list-users.sh) \
            'Voltar' ''         )


[ $? -ne 0 ] && src/dldap-users.sh

if [ $? -eq 1 ]; then
        if [ $resposta = 'Voltar' ];then
                ./src/dldap-users.sh
		exit
        else
                src/user/remove-user.sh $resposta
		src/user/remove-user-from-group.sh $resposta
        fi
fi

dialog                                            \
  --backtitle 'DLDAP - Excluir Usuário'                 \
   --title 'Finalizado!'                             \
   --msgbox 'Exclusão realizada com sucesso!'  \
   6 40

src/dldap-users.sh
