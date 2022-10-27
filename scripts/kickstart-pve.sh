#!/usr/bin/env bash

apt-get update
apt-get install sudo

echo "Enter non-root admin user name:"
read USERNAME

adduser $USERNAME
usermod -aG sudo $USERNAME