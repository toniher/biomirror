Terraform recipe for setting up a RDS Aurora MySQL database for supporting the scripts

```
terraform plan --target=module.vpc --out=vpc.plan
terraform apply vpc.plan
terraform plan
terraform apply
```

# TODO

* SNS email notification when done
** http://aws-cloud.guru/terraform-sns-topic-email-list/
** https://stackoverflow.com/questions/67348642/can-we-add-an-sns-topic-from-terraform-with-email-subscription

* Move lambda function to Module
  