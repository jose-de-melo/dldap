#!/bin/bash

user=$1


dialog --backtitle "DLDAP - Excluir Usuário: $user" --title 'Confirmar Exclusão' --yesno "Confirmar exclusão do usuário $user?\n\nATENÇÃO: O usuário será excluído por completo, incluindo o grupo criado com o mesmo nome do usuário." 10 60

if [ $? = 0 ]; then
        echo "EXCLUÍDO!"
else
        echo 'CANCELADO!'
fi
