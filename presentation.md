# Ansible

---

## Provisioning

- **Automated** setup of machines
- Configuration lives in **source control**
- **Declarative** - This is what the machine should look like

---

## Provisioning

- Ansible
- Puppet
- Chef
- Salt
- Terraform
- ...

the list is getting longer

---

## Ansible

- Connects over SSH
- No agent on the provisioned machines
- YAML configuration

---

## Terms

- host
- group
- inventory
- fact
- playbook
- role

---

## Roles

- task
- template
- handler

---

# Starter project

What's in the sample project?

- ansible.cfg
- inventory
- playbook
- role

---

# inventory/hosts

```ini
[web]
web1

[server]
web1
web3
```

---

# Facts

Facts are the things ansible can find out about a system.

```shell
ansible web -m setup
```

_Make sure that you can run this script now_

^ This checks that the environment is running as expected.

---

# playbooks/motd.yml

```yaml
- hosts: server
  roles:
    - role: motd
```

---

# roles/motd/tasks/main.yml

```yaml
- name: motd | install motd
  copy:
    src: motd
    dest: /etc/motd
    owner: root
    group: root
    mode: 0644
```

---

# Let's give it a go

```shell
ansible-playbook playbooks/motd.yml
```

_Give it a go_

^ Get everyone to try it then demonstrate

^ Show that first you get changed then you get OK

^ Show that it updated web1 and web3

---

# Hands On

Time for some hands on - **Workshop 1**

^ Live implement workshop 1 on screen

^ Discuss jinja templating

^ Show that web 1 and 3 update

---

# Hands On

Time for some hands on - **Workshop 2**

^ Live implement workshop 2 on screen

^ cat /proc/sys/kernel/random/entropy_avail

^ Show that web 1 and 3 update - but that nothing starts running

---

# Handlers

Handlers are how you can stop, start, restart services.

Since it is possible that several things can need to cause a restart, each recipe can "notify" a handler, and then at the end - any handler with at least one notification will trigger.

^ Add a start handler to haveged

^ Show that it doesn't do much for web 1 and 3

^ Add web 2 and show that it does start haveged

---

# Ansible Galaxy

Ansible Galaxy is a site where people can share finished ansible roles for different things.

---

# Hands On

Time for some hands on - **Workshop 3**

^ Live implement workshop 3 on screen

^ Discuss galaxy install vs requirements.yml

---

# Host and Group Variables

Facts do not provide everything we need for configuring a system. We also often need other information.

Ansible handles this by use of variables.

^ Possible locations

Commonly - we define them in the inventory.

In the same directory as the hosts file - we can add both a `group_vars` and a `host_vars` directory.

---

# Hands On

Time for some hands on - **Workshop 4**

^ Live implement workshop 4 on screen

---

# Putting it all together

Time for some hands on - **Workshop 5**

^ Live implement workshop 5 on screen

---

# Other stuff

---

## Configuration as code

An ansible setup should be maintained in a change control system (git, svn, tfs etc) just as we do source code for projects.

Changes should be made using similar processes (feature branches, code review etc) that are used as best practices in development.

---

## Ansible Vaults

Ansible uses ansible-vault to allow you to encrypt files.

Most often variables files under the `host_vars` and `group_vars` area.

This allows you to have passwords etc in the variables, under change control but not openly readable.

---

## Running as root

For this workshop we kept things simple by allowing you to run everything by using ssh as the root user.

Ansible has support for allowing you to connect as a non-root user and to safely escalate priviliges where needed.

---

## Role dependencies

There may well be some cases where you want to have dependencies on another role.

These can be configured in the role/meta/main.yml files.

---

## Ansible Tower

Ansible Tower is a commercial product from RedHat that helps in larger deployment scenarios.

There are some open source alternatives - for example:

- AWX which is the open source upstream for tower
- Semaphore

**AWX Demo**

---

# Where to go from here

- https://github.com/geerlingguy/ansible-for-devops
- https://github.com/geerlingguy/ansible-vagrant-examples
