#!/bin/bash

backtitle=$1
title=$2
message=$3



dialog	\
  --cr-wrap                                            \
  --backtitle "$backtitle"                \
   --title "$title"                             \
   --msgbox "$message"  \
   6 40
