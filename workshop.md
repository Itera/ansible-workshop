# Starter project - part 1

## ansible.cfg

Here we setup some default stuff - paths etc.

## inventory

The inventory is where we tell ansible what machines it will be working with - in groups.

Start with the inventory/hosts file - this is where we tell ansible what machines are in which groups. Initially - only web1 and web3 are marked as `server` and only web1 as `web`. We will change this later on.

# Facts

Facts are the things ansible can find out about a system. From the ansible project directory - try running the following:

```shell
ansible web -m setup
```

That asks ansible to run the setup module (gathers facts) for all machines in group web (which it knows about because the inventory path in ansible.cfg points to the inventory hosts file where this grouping is specified).

The facts returned are printed to stdout.

# Starter project - part 2

Let's look at a simple role.

A role is a directory - and will always have a tasks folder. It may have other folders (files, handlers, templates etc).

The default yaml file it will load when loading a task is main.yml.

So - we have a sample role that will set the message of the day file to a simple text.

- roles/motd/tasks/main.yml - copies the file
- roles/motd/files/motd - the file we want to copy to the server

Then we setup a playbook - which tells ansible what roles to run for which servers.

- playbooks/motd.yml - says to run the motd role for all machines in the server group

Let's run it:

```shell
ansible-playbook playbooks/motd.yml
```

It should install the motd file on web1 and web3.

You should see in the output that the file is "changed".

If you run it again what happens?

You should see in the output that the file is "ok".

# Workshop 1

The motd recipe installs the same message on all machines. That's OK - but it would be nice to have the hostname in the text of the message so that we know what server we are connecting to.

To do this - we need to move from a static file to a generated one.

For templates like this ansible uses the jinja2 templating language.

## Task

- Create a templates directory under roles/motd
- Create a motd.j2 file in templates
- Create the contents of the file using jinja2
  - you can add any fact as text by wrapping it in {{ }}
  - can you find a fact that allows you to have the motd "Welcome to &lt;hostname&gt;" ?
- Change the tasks file to create the motd from template:
  - templates use the template module instead of the copy module
- Tidy up by removing the files/motd file

Re-run the playbook and then check that the motd is changed on web1 and web3.

# Workshop 2

Linux servers have a system entropy that is used in random number generation. This gets data from keyboard and mouse events, a very little from network activity etc. On modern servers - entropy can be a little low - which will cause performance problems in anything requiring random numbers (ssh, ssl etc).

There is a method called [HAVEGE](http://www.irisa.fr/caps/projects/hipsor/) for adding additional entropy and there is a linux package for that called haveged.

Let's install that package

First - let's check the current entropy on the system - ssh into one of the web boxes and then run

    cat /proc/sys/kernel/random/entropy_avail

If it's under 2000 or so - then the system needs more entropy.

## Task

- Create a new role called haveged
- Create the tasks folder and main.yml files for that role
- Create the package installer task in main.yml to install epel-release
  - Use the yum module
- Create the package installer task in main.yml to install haveged
  - Use the yum module
- Create a playbook for haveged in the playbooks directory
  - Set it up so that it runs the haveged role for servers in the `server` group
- Run the playbook

This should install haveged on web1 and web3 only. SSH into web1 or web3 and check the entropy level. It is still too low. If you check you will find that haveged isn't actually running.

To handle starting and stopping services we need to discuss handlers.

# Handlers

Handlers are how you can stop, start, restart services.

Since it is possible that several things can need to cause a restart, each recipe can "notify" a handler, and then at the end - any handler with at least one notification will trigger.

Let's add a handler to the haveged role

- create the directory roles/haveged/handlers
- create the file roles/haveged/handlers/main.yml

```yaml
- name: haveged | start
  service:
    name: haveged
    state: started
```

- add the notification to the tasks/main.yml haveged task

```yaml
notify:
  - haveged | start
```

Run the haveged playbook again - it should give you OK messages for the two tasks. Since nothing changed - it doesn't start haveged.

Let's include web2 in the mix - in the inventory file - add web2 to the `server` list and then run the haveged playbook once more.

This should show OK for things on web1 and web3, changed for things on web2 and should also trigger the handler for starting haveged on web2.

Check the entropy on web1/web3 vs. web2 - it should be a lot higher on web2 (somewhere close to 2500).

Handlers can be used for most normal state changes - start, stop, restart. It is fairly common to use the installation of a package to trigger a start handler and anything that changes configuration to trigger a restart handler.

# Ansible Galaxy

Ansible Galaxy is a site where people can share finished ansible roles for different things.

# Workshop 3

We're going to use the nginx role from nginxinc to install a running nginx.

The galaxy role we are going to install is https://galaxy.ansible.com/nginxinc/nginx

This shows us which OS's are supported. CentOS 7 is on the list - so we should be good to go.

First - we need to install the role.

```shell
ansible-galaxy install nginxinc.nginx
```

This should download the role and extract it into the roles directory.

## Task 1

Now - we can use this in a playbook to install nginx on the `web` machines.

Create a playbook called nginx.yml:

- Target the `web` servers
- Install the role nginxinc.nginx
- Include web2 in the list of `web` servers in the inventory/hosts file

Run the playbook - it should install nginx on web1 and web2. Note that it skips things that are not relevant to CentOS.

Check that it is running.

```shell
curl -o - http://web1
curl -o - http://web2
curl -o - http://web3
curl -o - http://web4
```

The first two should return the default welcome to nginx page, the others should return a connection error.

## Task 2

Nginx is now installed and running - we want to customize it.

We will install a page into the default nginx directory that is a text file containing the current hostname.

- Create a role called nginx.
- Create tasks and templates directories for that role
- In the templates directory - create a `hello.txt.j2` file that uses the `ansible_hostname` fact
- In the tasks directory - create a main.yml that uses the template module to install this template to `/usr/share/nginx/html/hello.txt`
- Add the nginx role to the list of roles in the nginx playbook after the nginxinc.nginx line

Check that you get the correct information from http://web1/hello.txt and http://web2/hello.txt

## Requirements

Installing galaxy roles into your repository is not the best design choice.

To help you - you can use galaxy's support for requirements.yml

```yaml
- src: nginxinc.nginx
```

And run it with

```shell
ansible-galaxy install -r requirements.yml
```

Still not great - but better than manual installation.

# Host and Group Variables

Facts do not provide everything we need for configuring a system. We also often need other information.

Ansible handles this by use of variables. These can be defined in many places. They can be defined in the relevant role for example.

But - more commonly - we define them in the inventory.

In the same directory as the hosts file - we can add both a `group_vars` and a `host_vars` directory.

# Workshop 4

Let's add a group variable that can be used by all hosts in web, and a host variable per host - and add them to hello.txt

## Task

First create the following directories:

- `inventory/group_vars/web`
- `inventory/host_vars/web1`
- `inventory/host_vars/web2`
- `inventory/host_vars/web3`
- `inventory/host_vars/web4`

In `inventory/group_vars/web` create a file called nginx.yml with the contents:

```yaml
web_hello_text: "Hello Web World"
```

And for each host_var directory - an nginx.yml file with the contents:

```yaml
host_hello_text: "Hello World from host x"
```

Where x is the name of the host (web1, web2, web3, web4)

Now - change the hello.txt.j2 template to use these - something like this:

```jinja2
Hello From Nginx

Web: {{ web_hello_text }}

Host: {{ host_hello_text }}
```

Finally - add web3 to the `web` group in the inventory/hosts file

Run the playbook to update web1, web2 and web3.

You can use the same curl command to check that the details were updated. Make sure that the host variable is correct per host.

# Worshop 5 - Putting it all together

OK - we have now got a setup we want to use as our basis web machine.

So far we have installed different things at different times on web1, web2 and web3 but we have done nothing on web4.

Let's create a playbook that does it all for us and then use that to also include web4.

```yaml
- hosts: server
  roles:
    - role: motd
    - role: haveged

- hosts: web
  roles:
    - role: nginxinc.nginx
    - role: nginx
```

Then in the inventory/hosts file - add web4 to the list of `web` hosts and to the list of `server` hosts.

Finally run the playbook and see that web4 is now properly provsioned:

- motd is updated
- haveged is installed and running - entropy is (likely) above 2000
- nginx is installed and running
- http://web4/hello.txt has the correct data

# Other stuff

## Configuration as code

An ansible setup should be maintained in a change control system (git, svn, tfs etc) just as we do source code for projects. Changes should be made using similar processes (feature branches, code review etc) that are used as best practices in development.

## Ansible Vaults

Ansible uses [ansible-vault](https://docs.ansible.com/ansible/2.7/user_guide/vault.html) to allow you to encrypt files (most often variables files under the host_vars and group_vars area). This allows you to have passwords etc in the variables, under change control but not openly readable.

You will have to distribute the vault password outside of the repository.

My personal method is to have the vault password gpg encrypted inside the repository and to call ansible-playbook with a script that looks like:

```shell
if [ ! -f vault-password.txt ]; then
  gpg2 --decrypt-files vault-password.txt.gpg
fi

ansible-playbook $@
```

And in my ansible.cfg I have

```ini
vault_password_file = vault-password.txt
```

But this requires either a shared gpg key or that the committed encrypted password file is encrypted for everyone that needs it. This may not scale well.

## Running as root

For this workshop we kept things simple by allowing you to run everything by using ssh as the root user. This is often not the best practice. Ansible has support for allowing you to connect as a non-root user and to safely escalate priviliges where needed.

- [Ansible "become" and privilege escalation](https://docs.ansible.com/ansible/2.7/user_guide/become.html)

## Role dependencies

There may well be some cases where you want to have dependencies on another role. These can be configured in the role/meta/main.yml files.

- [Ansible role dependencies](https://docs.ansible.com/ansible/2.7/user_guide/playbooks_reuse_roles.html#role-dependencies)

## Ansible Tower

[Ansible Tower](https://www.ansible.com/products/tower) is a commercial product from RedHat that helps in larger deployment scenarios.

There are some open source alternatives - for example:

- [AWX](https://github.com/ansible/awx) which is the open source upstream for tower
- [Semaphore](https://github.com/ansible-semaphore/semaphore)

We'll take a quick look at AWX together (presentation/demo) to finish off.

# What next?

- https://github.com/geerlingguy/ansible-for-devops
- https://github.com/geerlingguy/ansible-vagrant-examples
