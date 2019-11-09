#!/bin/bash

dialog                                           \
   --title 'Pergunta'                            \
   --radiolist 'Há quanto tempo você usa o Vi?'  \
   0 0 0                                         \
   $(./src/user/make-radio-users.sh)		 \
