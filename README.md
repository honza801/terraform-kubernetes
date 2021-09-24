# terraform kubernetes deployment

## terraform installation for debian

https://www.terraform.io/docs/cli/install/apt.html

## openstack

### get token from your cloud provider

in openstack find relevant auth data here
* Identity/Application Credentials/Create
* Project/Compute/Key Pairs
* API Access/Identity

### deploy multinode kubernetes

```
cd openstack/
cp -iv terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars
terraform apply
```

## opennebula
### get token from your cloud provider

* in opennebula goto User/Settings/Auth/Manage login tokens/Get a new token

### deploy multinode kubernetes

```
cd opennebula/
ssh-keygen -t ecdsa -N "" -f ../files/id_ecdsa
cp -iv terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars
terraform apply
```

