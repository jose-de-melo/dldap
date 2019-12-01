#!/bin/bash

##################
## Exibindo uma caixa com informações sobre a aplicação
##################
dialog --ok-label "Menu Principal" --backtitle "DLDAP" --title "Sobre o DLDAP" --msgbox "\nO DLDAP é o trabalho desenvolvido para a disciplina de Gerência e Configuração de Serviços Internet. O objetivo central do projeto é criar uma interface intuitiva para gerenciar usuários, grupos e hosts de uma base LDAP construída no Instituto Federal do Sudeste de Minas Gerais - Campus Barbacena. Para desenvolver a interface, foi utilizado o Dialog, que é um aplicativo usado em shell scripts que cria widgets (menus, avisos, barras de progresso, etc) em modo texto (CLI)." 15 70

## Exibindo a tela inicial da aplicação
./dldap.sh
