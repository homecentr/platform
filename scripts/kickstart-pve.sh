#!/usr/bin/env bash

apt-get update
apt-get install sudo

read -p "Enter non-root admin user name:" USERNAME </dev/tty

adduser $USERNAME
usermod -aG sudo $USERNAME