#!/usr/bin/env bash

# yarn install is executed automatically

ansible-galaxy install -r ./requirements.yaml --force
ansible-playbook ./playbooks/_local.yaml