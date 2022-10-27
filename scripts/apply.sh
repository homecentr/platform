#!/usr/bin/env bash

printHelp() {
  echo "Usage: apply (staging|prod) <playbook>"
}

case "$1" in
 staging)
  INVENTORY="./environments/staging"
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

if [ -z "$2" ]; then
  printHelp
  exit 1
fi

PLAYBOOK="./playbooks/$2.yml"

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