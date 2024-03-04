#!/usr/bin/env bash

# yarn install is executed automatically

ansible-galaxy install -r ./requirements.yaml --force
ansible-playbook ./playbooks/local/setup.yaml
ansible-playbook -i ./environments/lab/ ./playbooks/local/ssh.yaml
ansible-playbook -i ./environments/prod/ ./playbooks/local/ssh.yaml