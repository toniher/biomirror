Terraform recipe for setting up a RDS Aurora MySQL database for supporting the scripts

```
terraform plan --target=module.vpc --out=vpc.plan
terraform apply vpc.plan
terraform plan
terraform apply
```

# TODO


