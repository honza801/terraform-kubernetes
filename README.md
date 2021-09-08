terraform kubernetes deployment

```
ssh-keygen -t ecdsa -N "" -f ./files/id_ecdsa
cp -iv terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars
terraform apply
```

