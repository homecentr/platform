#!/usr/bin/env bash

apt-get update
apt-get install sudo

read -p "Enter non-root admin user name: " USERNAME </dev/tty
# read -p "Enter non-root admin user's full name: " USER_FULLNAME </dev/tty

adduser $USERNAME --disabled-password --gecos ''
usermod -aG sudo $USERNAME