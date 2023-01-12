#!/bin/bash

# Adding Zabbix repository for installing zabbix agent on Linux Centos7
sudo rpm -Uvh https://repo.zabbix.com/zabbix/5.4/rhel/7/x86_64/zabbix-agent-5.4.6-1.el7.x86_64.rpm
sudo yum install zabbix-agent zabbix-sender -y

# Adding zabbix server ip and host name. It's better to set that with appropriate IP and project URL
ZABBIX_SERVER_IP="10.10.10.10"
PROJECT_URL="zabbix_agent_bash"

sleep 2

cd /etc/zabbix

# Checking for the availability of zabbix_agent.conf and Use encryption method for sending data to Zabbix server
    if [ -f "zabbix_agentd.conf" ] ; then
    {
        sed -i "s\Server=127.0.0.1\Server=${ZABBIX_SERVER_IP}\g" zabbix_agentd.conf
        sed -i "s\ServerActive=127.0.0.1\ServerActive=${ZABBIX_SERVER_IP}\g" zabbix_agentd.conf
        sed -i "s\Hostname=Zabbix server\Hostname=${PROJECT_URL}\g" zabbix_agentd.conf
        sed -i "s\# TLSConnect=unencrypted\TLSConnect=psk\g" zabbix_agentd.conf
        sed -i "s\# TLSAccept=unencrypted\TLSAccept=psk\g" zabbix_agentd.conf
        sed -i "s\# TLSPSKFile=\TLSPSKFile=/etc/zabbix/secret.psk\g" zabbix_agentd.conf
        sed -i "s\# TLSPSKIdentity=\TLSPSKIdentity=${PROJECT_URL}\g" zabbix_agentd.conf
        sed -i "s\# Timeout=3\Timeout=4\g" zabbix_agentd.conf
    }
    else
        echo "zabbix.conf doesn exist"

    fi
# Creating hash code and changing ownership and mode
sudo openssl rand -hex 64 > secret.psk
sudo chown zabbix:zabbix secret.psk
chmod 640 secret.psk

#Showing the "secret key" hash code and "TLSPSKIdentity value" for adding in zabbix server's dashboard
echo "The secret.psk value is:"
cat secret.psk
echo "The TLSPSKIdentity value is:"
echo "$PROJECT_URL"

#Adding port in firewall permanently
sudo firewall-cmd --permanent --add-port=10050/tcp
sudo firewall-cmd --reload

#Finally, start Zabbix-agent, run it again after server reboot and show status of the zabbix agent  
sudo systemctl start zabbix-agent
sudo systemctl enable zabbix-agent
systemctl status zabbix-agent

 
