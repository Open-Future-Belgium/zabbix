#!/bin/bash
### Make sure yum-plugin-security package is installed ###
### Make sure zabbix-sender package is installed ###

### Set Some Variables ###
ZBX_DATA=/tmp/zabbix-sender-yum.in
HOSTNAME=$(egrep ^Hostname= /etc/zabbix/zabbix_agentd.conf | cut -d = -f 2)
ZBX_SERVER_IP=$(egrep ^ServerActive /etc/zabbix/zabbix_agentd.conf | cut -d = -f 2)
release=$(cat "/etc/redhat-release")
enforcing=$(getenforce)

### Check if Zabbix-Sender is Installed ###
if ! rpm -qa | grep -qw zabbix-sender; then
    echo "Zabbix-Sender NOT installed"
    exit 1;
fi

### Check if SELinux is active ###
if [[ "$enforcing" == "Enforcing" ]]
then
  selinux=1
else
  selinux=0
fi

### Check for Security Updates ###
Moderate=$(yum updateinfo list --sec-severity=Moderate | grep Moderate | wc -l)
Important=$(yum updateinfo list --sec-severity=Important | grep Important | wc -l)
Low=$(yum updateinfo list --sec-severity=Low | grep Low | wc -l)
Critical=$(yum updateinfo list --sec-severity=Critical | grep Critical | wc -l)


### Add data to file and send it to Zabbix Server ###
echo -n > $ZBX_DATA
echo "$HOSTNAME yum.moderate $Moderate" >> $ZBX_DATA
echo "$HOSTNAME yum.important $Important" >> $ZBX_DATA
echo "$HOSTNAME yum.low $Low" >> $ZBX_DATA
echo "$HOSTNAME yum.critical $Critical" >> $ZBX_DATA
echo "$HOSTNAME yum.release $release" >> $ZBX_DATA
echo "$HOSTNAME yum.selinux $selinux" >> $ZBX_DATA

zabbix_sender -z $ZBX_SERVER_IP -i $ZBX_DATA &> /dev/null

