#! /bin/sh

#################################################################################################
## checkro.sh
#################################################################################################
## Description: This script will test if a filesystem became read-only
##
## Script runs on: all zabbix agents
##
## UserParameter=custom.checkro[*],/opt/zabbix/scripts/checkro.sh $1
##    $1: filesystem
#################################################################################################
## Version   Date     By               Description
#################################################################################################
## 1.0
## Changes:
#################################################################################################

fs=$1

if [ `grep " ro," /proc/mounts | grep "$fs " | wc -l` -eq 1 ]
then
      echo 1
else
      echo 0
fi
exit
