#!/bin/sh

yum -y install epel-release
yum -y install ansible

if [ ! -d /root/ansible ]; then
  mkdir -p /root/ansible

  if [ -d /tmp/ansible ]; then
    mv /tmp/ansible/* /root/ansible
  fi

   chown root.root /root/ansible
fi