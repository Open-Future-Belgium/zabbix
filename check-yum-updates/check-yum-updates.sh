#!/bin/bash
### Make sure yum-plugin-security package is installed ###
### Make sure zabbix-sender package is installed ###

### Set Some Variables ###
ZBX_DATA=/tmp/zabbix-sender-yum.data
HOSTNAME=$(egrep ^Hostname= /etc/zabbix/zabbix_agentd.conf | cut -d = -f 2)
ZBX_SERVER_IP=$(egrep ^ServerActive /etc/zabbix/zabbix_agentd.conf | cut -d = -f 2)
RELEASE=$(cat "/etc/redhat-release")
ENFORCING=$(getenforce)

### Check if Zabbix-Sender is Installed ###
if ! rpm -qa | grep -qw zabbix-sender; then
    echo "Zabbix-Sender NOT installed"
    exit 1;
fi

### Check if SELinux is active ###
if [[ "$ENFORCING" == "Enforcing" ]]
then
  SELINUX=1
else
  SELINUX=0
fi

### Check for Security Updates ###
MODERATE=$(yum updateinfo list --sec-severity=Moderate | grep Moderate | wc -l)
IMPORTANT=$(yum updateinfo list --sec-severity=Important | grep Important | wc -l)
LOW=$(yum updateinfo list --sec-severity=Low | grep Low | wc -l)
CRITICAL=$(yum updateinfo list --sec-severity=Critical | grep Critical | wc -l)


### Add data to file and send it to Zabbix Server ###
echo -n > $ZBX_DATA
echo "$HOSTNAME yum.moderate $MODERATE" >> $ZBX_DATA
echo "$HOSTNAME yum.important $IMPORTANT" >> $ZBX_DATA
echo "$HOSTNAME yum.low $LOW" >> $ZBX_DATA
echo "$HOSTNAME yum.critical $CRITICAL" >> $ZBX_DATA
echo "$HOSTNAME yum.release $RELEASE" >> $ZBX_DATA
echo "$HOSTNAME yum.selinux $SELINUX" >> $ZBX_DATA

zabbix_sender -z $ZBX_SERVER_IP -i $ZBX_DATA &> /dev/null

