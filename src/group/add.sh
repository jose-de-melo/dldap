#!/bin/bash


uid=$( dialog --stdout                         \
   --backtitle 'DLDAP - Adicionar Grupo'      \
   --title 'Novo Grupo:'                         \
   --inputbox '\n\nUsername (uid): '  \
   13 50 )
