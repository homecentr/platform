#!/usr/bin/env bash

printHelp() {
  echo "Usage: apply (lab|prod) <playbook>"
}

case "$1" in
 lab)
  INVENTORY="./environments/lab"
  ;;
 prod)
  INVENTORY="./inventories/prod"
  ;;
 *)
  # else
  printHelp
  exit 1
  ;;
esac

PLAYBOOK="./playbooks/${2:-site}.yml"

if [ ! -f "$PLAYBOOK" ]; then
  printHelp
  echo "Playbook $PLAYBOOK could not be found"
fi

shift
shift

export ANSIBLE_CONFIG="./ansible.cfg"

# Install Ansible dependencies (roles and collections)
ansible-galaxy install -r ./requirements.yml

COMMAND="ansible-playbook -i $INVENTORY $PLAYBOOK --vault-password-file ./scripts/vault.sh $@"

# Execute playbook
eval $COMMAND