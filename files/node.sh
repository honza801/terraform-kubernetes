#!/bin/bash

# prepare node
mkdir /root/.ssh
chmod 700 /root/.ssh

cat >> /root/.ssh/authorized_keys2 <<KEY2
${ public_key }
KEY2
