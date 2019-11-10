#!/bin/bash


user='ricardo'
gecos="Ricardo Vitor"

cp ldifs/user.ldif tmp.ldif

sed "12c\gecos: $gecos" tmp.ldif >> $user.ldif
cat $user.ldif
rm -rf tmp.ldif
