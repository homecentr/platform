## Structure and conventions

```yaml
inventories/
├── <environment>
|   ├── group_vars/
|   |   ├── <group-name>/
|   |   |   └── some-file.yml # Variables applied to hosts in the group
|   |   └── all.yml           # Variables applied to all hosts
|   ├── host_vars/
|   |   └── <hostname>.yml    # Contains variables applied to specific hosts
|   ├── hosts                 # List of hosts in the environment and their mapping to groups/
|   └── secrets               # Secrets stored as ansible variables encrypted by ansible-vault
playbooks/
|   └── <playbook>.yml
roles/
|   └── <group>
|       └── <role>            
ansible.cfg
```

## Local set up
Working with this repository requires installation of several command line tools, please use the [dev-setup](https://github.com/lholota/dev-setup) repo and apply the playbook with following tags:
- sops
- yubikey (optional)

## Release process
- Create a Lab environment
- Apply the current playbooks from master
- Make and test your changes against the Lab environment
- Test the changes against a freshly build Lab environment
- Merge changes to master via Pull request which will run basic validations
- Checkout master and apply against Production cluster

## Environments

- **Lab** - test environment used to develop the roles. The environment is defined in the [lab](https://github.com/homecentr/lab) repository using Proxmox nested virtualization. Please refer to this repository on how to (re)create this environment.
- **Production** - the actual deployment used by the users.

## Applying playbooks
In case you are running the playbooks against freshly installed machines, make sure you first run the initialization using the `yarn lab:init` command.

To apply a playbook simply run the following bash command (requires Linux e.g. in WSL with [Yarn](https://yarnpkg.com/) installed):
```
yarn <env>:apply <playbook>
```

for example `yarn lab:apply common.yml`

The script automatically installs dependencies from Ansible Galaxy and runs the playbook.
