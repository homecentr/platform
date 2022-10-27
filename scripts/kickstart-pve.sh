#!/usr/bin/env bash

apt-get update
apt-get install sudo

read -p "Enter non-root admin user name: " USERNAME </dev/tty

adduser $USERNAME </dev/tty
usermod -aG sudo $USERNAME