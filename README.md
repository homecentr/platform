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
.vault-pass.gpg               # Vault password encrypted by a hardware token
```

## Release process
- Create a Lab environment
- Apply the current playbooks from master
- Make and test your changes against the Lab environment
- Test the changes against a freshly build Lab environment
- Merge changes to master via Pull request which will run basic validations
- Checkout master and apply against Production cluster

## Environments

- **Lab** - test environment used to develop the roles running locally inside of HyperV on a developer's workstation.
- **Production** - the actual deployment used by the users.

### Create a Lab environment in Hyper-V
- Make sure you are running Windows 11 because earlier versions do not support nested virtualization which is required
- Install latest version of Powershell using [this guide](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.2)
- Create VMs using `yarn lab:create` command (must be executed as administrator)
- Start the VMs and install the Proxmox VMs with following parameters  
    - Disk: ZFS with RAID0
    - Country: Czechia
    - Timezone: Europe/Prague
    - Password: any, just watch out for english keyboard layout when typing numbers and make sure **all nodes have the same password**
    - E-mail: stg-pve&lt;X&gt;@lab.&lt;domain&gt;
    - Hostname: stg-pve&lt;X&gt;.lab.&lt;domain&gt;
    - IP Address: 10.1.8.1&lt;X&gt;/24
    - Gateway: 10.1.8.1
- Configure storage network
    - IP Address: 192.168.1.1&lt;X&gt;/24 (this is an internal HyperV network)
    - Do not set a gateway
- Create a Proxmox cluster (there's currently no way to automate this)
- Remove previous SSH keys in case you have re-created the lab using the following command
```bash
yarn lab:clear-keys
```
- Apply Ansible playbooks which will set up ssh access using the standard admin user using the following command
```bash
ANSIBLE_HOST_KEY_CHECKING=False yarn lab:apply proxmox -u root -e ansible_user=root --tags init -k
```
- Apply the rest of Ansible playbooks using the following command
```bash
yarn lab:apply site
```

## Applying playbooks
Simply run the following bash command (requires Linux e.g. in WSL with [Yarn](https://yarnpkg.com/) installed):
```
yarn <env>:apply <playbook>
```

for example `yarn lab:apply common.yml`

The script automatically installs dependencies from Ansible Galaxy and runs the playbook.

> Note that the first time applying playbooks on a clean server, you need to use whatever authentication is available (most likely a password based one). During the first run the roles configure the SSH daemon to only allow non-root user with an RSA key and/or hardware device like YubiKey you need to use for subsequent logins.

## Ansible Vault
The playbooks use several sensitive variables which are therefore encrypted using Ansible Vault. The vault passphrase is committed into the repository because it is encrypted using gpg with YubiKey. To set from scratch, follow [this guide](https://disjoint.ca/til/2016/12/14/encrypting-the-ansible-vault-passphrase-using-gpg/). This does not give you access to the original passphrase, just the tooling to set up your own. Each user must have their own encrypted version of the password.

To change the encrypted variables, use the `yarn <lab>:secrets <path>` command (e.g. `yarn lab:secrets`).