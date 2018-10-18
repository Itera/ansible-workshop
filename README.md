# Ansible workshop

## Prerequisites

The workshop expects you to have virtualbox and vagrant installed beforehand.

### Windows

* https://www.virtualbox.org/wiki/Downloads
* https://www.vagrantup.com/downloads.html

### Linux

* https://www.virtualbox.org/wiki/Linux_Downloads
* https://www.vagrantup.com/downloads.html

### Mac

* https://www.virtualbox.org/wiki/Downloads
* https://www.vagrantup.com/downloads.html

OR

```
brew cask install virtualbox
brew cask install vagrant
```

## Initialize the vagrant machines

First let's do the initial startup - this could take a few minites - it is creating 4 machines.

```
vagrant up
```

This does several things:

* Creates 4 Centos 7 machines
* Sets up that root can use ssh to connect
* Sets up the ssh keys for root (the same on all machines)
* Sets up the local hosts files for each machine so that we can use hostnames
* Installs ansible on the ansible machine
* Copies the starter project onto the ansible machine

This provides us with a simple setup where ansible is installed and can use ssh to connect to the machines that it want's to provision.

Note that the ssh keys used here were generated for this workshop and should only be used in the virtual machines here - since they are publically available via this repository.

The four machines that are set up are:

* ansible - the VM you will use to run ansible
* web1, web2, web3 - three machines that we want to use as webservers.

## Starter project 1

### ansible.cfg

Here we setup some default stuff - paths etc.

### inventory/hosts

Start with the inventory/hosts file - this is where we tell ansible what machines are in which groups. Initially - all three are marked as servers but only one is in web. We will add the others here later on.

## Facts

Facts are the things ansible can find out about a system. From the ansible project directory - try running the following:

```
ansible web -m setup
```

That asks ansible to run the setup module (gathers facts) for all machines in group web (which it knows about because the inventory path in ansible.cfg points to the inventory hosts file where this grouping is specified).

The facts returned are printed to stdout.

## Starter project 2

Let's look at a simple role.

A role is a directory - and will always have a tasks folder. It may have other folders (files, handlers, templates etc).

The default yaml file it will load when loading a task is main.yml.

So - we have a sample role that will set the message of the day file to a simple text.

* roles/motd/tasks/main.yml - copies the file
* roles/motd/files/motd - the file we want to copy to the server

Then we setup a playbook - which tells ansible what roles to run for which servers.

* playbooks/demo1.yml - says to run the motd role for all machines in the server group

Let's run it:

```
ansible-playbook playbooks/demo1.yml
```

It should install the motd file on all three web machines.

You should see in the output that the file is "changed".

If you run it again what happens?

You should see in the output that the file is "ok".

Note that the very first time ssh is used to connect to a machine it will ask if you want to add the host key to the list of known hosts (standard ssh behaviour). You can either ssh manually into web1, web2 and web3 first - or just say yes three times when running the playbook the first time.
