#!/bin/bash

# prepare node
mkdir /root/.ssh
chmod 700 /root/.ssh
cat > /root/.ssh/id_ecdsa <<KEY1
${ private_key }
KEY1
chmod 600 /root/.ssh/id_ecdsa

cat > /root/.ssh/id_ecdsa.pub <<PUBKEY
${ public_key }
PUBKEY

cat >> /root/.ssh/authorized_keys2 <<KEY2
${ public_key }
KEY2
echo StrictHostKeyChecking no >> /root/.ssh/config

# get kubespray
KUBESPRAY=/root/kubespray
apt update -qq
apt install -y ansible git vim nano- python3-pip
git clone https://github.com/kubernetes-sigs/kubespray.git $KUBESPRAY
cd $KUBESPRAY

### FROM KUBESPRAY
pip3 install -r requirements.txt

# Install dependencies from ``requirements.txt``
sudo pip3 install -r requirements.txt

# Copy ``inventory/sample`` as ``inventory/mycluster``
cp -rfp inventory/sample inventory/mycluster

# Update Ansible inventory file with inventory builder
source /var/run/one-context/one_env
declare -a IPS=($ETH0_IP $KUBENODES)
CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py $${IPS[@]}

# Review and change parameters under ``inventory/mycluster/group_vars``
cat inventory/mycluster/group_vars/all/all.yml
cat inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml

# Deploy Kubespray with Ansible Playbook - run the playbook as root
# The option `--become` is required, as for example writing SSL keys in /etc/,
# installing packages and interacting with various systemd daemons.
# Without --become the playbook will fail to run!
ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root cluster.yml
