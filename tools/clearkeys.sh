#!/usr/bin/env bash

ssh-keygen -f ~/.ssh/known_hosts -R 10.1.8.11
ssh-keygen -f ~/.ssh/known_hosts -R 10.1.8.12
ssh-keygen -f ~/.ssh/known_hosts -R 10.1.8.13

ssh-keygen -f ~/.ssh/known_hosts -R 10.1.8.21
ssh-keygen -f ~/.ssh/known_hosts -R 10.1.8.22
ssh-keygen -f ~/.ssh/known_hosts -R 10.1.8.23