#!/usr/bin/bash
if [ $# -ge 1 ]
then
 for param in $@
 do
  if [ -f $param ]
  then 
   chmod 777 $param
   ./$param
  fi
 done
fi
