#!/bin/bash

###################
## Configuração desejada pelo usuário. Opções: base, user, userPassword.
###################
config=$1

##################
## Exibindo apenas o valor da opção escolhida, usando a combinação dos comandos cat, grep e cut.
##################

cat .config | grep "$config:" | cut -d":" -f2


