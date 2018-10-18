#!/bin/sh

grep -q -F 'PermitRootLogin yes' /etc/ssh/sshd_config || echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

service sshd restart

mkdir -p /root/.ssh

if [ -d /tmp/.ssh ]; then
  mv /tmp/.ssh/* /root/.ssh
fi

if [ -d /root/.ssh ]; then
  chmod 755 /root/.ssh
  chmod 600 /root/.ssh/id_rsa
  chmod 644 /root/.ssh/id_rsa.pub
  cp /root/.ssh/id_rsa.pub /root/.ssh/authorized_keys
  chown root.root /root/.ssh
fi

grep -q -F 'ansible' /etc/hosts || echo "10.20.1.10 ansible ansible.localdomain" >> /etc/hosts
grep -q -F 'web1' /etc/hosts || echo "10.20.1.11 web1 web1.localdomain" >> /etc/hosts
grep -q -F 'web2' /etc/hosts || echo "10.20.1.12 web2 web2.localdomain" >> /etc/hosts
grep -q -F 'web3' /etc/hosts || echo "10.20.1.13 web3 web3.localdomain" >> /etc/hosts
