#!/usr/bin/env bash

# ansible requires acl to be installed
apt-get install -y acl

# we provision with user "ubuntu", not "vagrant", so we need SSH access
cp /home/vagrant/.ssh/authorized_keys /home/ubuntu/.ssh/authorized_keys
