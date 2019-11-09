#!/bin/bash


user='ricardo'
gecos="Ricardo Vitor"

cp user.ldif tmp.ldif

sed "12c\gecos: $gecos" tmp.ldif >> $user.ldif

rm -rf tmp.ldif
