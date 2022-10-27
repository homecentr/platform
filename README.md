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

## Environments

- **Lab** - test environment used to develop the roles running locally inside of HyperV on a developer's workstation.
- **Production** - the actual deployment used by the users.

### Create a Lab environment in Hyper-V
- Make sure you are running Windows 11 because earlier versions do not support nested virtualization which is required
- Install latest version of Powershell using [this guide](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.2)
- Create VMs using `yarn lab:create` command (must be executed as admin)
- Download [Proxmox VE installation image](https://www.proxmox.com/en/downloads/category/iso-images-pve) and mount it to VMs' DVD drives
- Install the Proxmox VMs with following parameters  
    - Disk: ZFS with RAID0
    - Country: Czechia
    - Timezone: Europe/Prague
    - Password: any, just watch out for english keyboard layout when typing numbers
    - E-mail: stg-pve&lt;X&gt;@lab.&lt;domain&gt;
    - Hostname: stg-pve&lt;X&gt;.lab.&lt;domain&gt;
    - IP Address: 10.1.8.1&lt;X&gt;/24
    - Gateway: 10.1.8.1
    - Follow the general node preparation guidelines below
    - Follow Proxmox manual set up steps
- Install Debian based Kubernetes nodes VM inside each of Proxmox node
    - Follow the general node preparation guidelines below

### Preparing a new node
Kickstart the node using the bash as shown below:
```bash
curl https://raw.githubusercontent.com/homecentr/platform/master/scripts/kickstart-pve.sh | bash
```

## Applying playbooks
Simply run the following bash command (requires Linux e.g. in WSL with [Yarn](https://yarnpkg.com/) installed):
```
yarn <env>:apply <playbook>
```

for example `yarn staging:apply common.yml`

The script automatically installs dependencies from Ansible Galaxy and runs the playbook.

> Note that the first time applying playbooks on a clean server, you need to use whatever authentication is available (most likely a password based one). During the first run the roles configure the SSH daemon to only allow non-root user with an RSA key and/or hardware device like YubiKey you need to use for subsequent logins.

## Ansible Vault
The playbooks use several sensitive variables which are therefore encrypted using Ansible Vault. The vault passphrase is committed into the repository because it is encrypted using gpg with YubiKey. To set from scratch, follow [this guide](https://disjoint.ca/til/2016/12/14/encrypting-the-ansible-vault-passphrase-using-gpg/). This does not give you access to the original passphrase, just the tooling to set up your own. Each user must have their own encrypted version of the password.

To change the encrypted variables, use the `yarn secrets:edit <path>` command (e.g. `yarn secrets:edit prod/secrets.yml`), or `yarn secrets:init <path>` to create a new variable file.