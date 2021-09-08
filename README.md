# terraform kubernetes deployment

## terraform installation for debian

https://www.terraform.io/docs/cli/install/apt.html

## get token from your cloud provider

* in opennebula goto user->settings->auth->manage login tokens->get a new token

## deploy multinode kubernetes

```
ssh-keygen -t ecdsa -N "" -f ./files/id_ecdsa
cp -iv terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars
terraform apply
```

