#!/bin/bash
whoami
apt update
apt install firewalld -y
snap install microk8s --classic
microk8s status --wait-ready
iptables-save > ~/iptables-rules
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -F
firewall-cmd --zone=public --permanent --add-port=80/tcp
firewall-cmd --zone=public --permanent --add-port=443/tcp
firewall-cmd --zone=public --permanent --add-port=10443/tcp
firewall-cmd --zone=public --permanent --add-port=10250/tcp
firewall-cmd --zone=public --permanent --add-port=10255/tcp
firewall-cmd --zone=public --permanent --add-port=25000/tcp
firewall-cmd --zone=public --permanent --add-port=12379/tcp
firewall-cmd --zone=public --permanent --add-port=10257/tcp
firewall-cmd --zone=public --permanent --add-port=10259/tcp
firewall-cmd --zone=public --permanent --add-port=19001/tcp
firewall-cmd --zone=public --permanent --add-port=30000-33999/tcp
firewall-cmd --reload