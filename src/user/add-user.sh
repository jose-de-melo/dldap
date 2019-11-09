#!/bin/bash

user=$( dialog --stdout                                           \
   --backtitle 'DLDAP - Cadastrar Usuário'	\
   --title 'Novo Usuário'                         \
   --inputbox '\n\nNome (uid):'  \
   13 50 )

gecos=$( dialog --stdout                                           \
   --backtitle 'DLDAP - Cadastrar Usuário'      \
   --title 'Novo Usuário'                         \
   --inputbox '\n\nGecos: '  \
   13 50 )

password=$( dialog --stdout                                           \
   --backtitle 'DLDAP - Cadastrar Usuário'      \
   --title 'Novo Usuário'                         \
   --passwordbox '\n\nSenha: '  \
   13 50 )


echo $user $gecos $password

