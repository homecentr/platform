#!/usr/bin/env bash

# yarn install is executed automatically

ansible-galaxy install -r ./requirements.yaml --force

if [ -z "${SKIP_PLAYBOOKS}" ]; then
    ansible-playbook ./playbooks/local/setup.yaml
    ansible-playbook -i ./inventory/ ./playbooks/local/ssh.yaml
fi