## Vagrant

We are going to use vagrant to give everyone the same environment.

We will set up 5 machines, one working machine where we will run ansible and four machines that we want to provision.

You could choose to use the ansible code towards multiple instances in a cloud solution etc - there is nothing vagrant specific about them - but for the workshop this just makes sure that everyone is on the same page.

### Vagrant initialization

First let's do the initial startup - this could take a few minutes - it is creating 5 machines.

```
vagrant up
```

This does several things:

- Creates 5 Centos 7 machines
- Sets up that root can use ssh to connect
- Sets up the ssh keys for root (the same on all machines)
- Sets up the local hosts files for each machine so that we can use hostnames
- Installs ansible on the ansible machine
- Copies the starter project onto the ansible machine

This provides us with a simple setup where ansible is installed and can use ssh to connect to the machines that it wants to provision.

Note that the ssh keys used here were generated for this workshop and should only be used in the virtual machines here - since they are publically available via this repository.

The four machines that are set up are:

- ansible - the VM you will use to run ansible
- web1, web2, web3, web4 - three machines that we want to use as webservers.

## Login to the workspace

We need to login to the ansible machine where we will run the exercises.

To do so - we ssh into the ansible box (this happens as the vagrant user) then we switch to root.

The very first time you do this - you should run the ssh-keyscan line (just the one time) - it sets up the ssh known_hosts file so that you don't get asked if you want to add the hosts later on.

Finally we switch to the ansible directory where the basic setup for the workshop has been placed for you by the vagrant setup scripts.

```
vagrant ssh ansible
sudo su -
ssh-keyscan -H web1 web2 web3 web4 10.20.1.11 10.20.1.12 10.20.1.13 10.20.1.14 > .ssh/known_hosts
cd ansible
```

All steps after this assume that you are logged in to this workspace.
