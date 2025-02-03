#!/bin/bash

stskeygen --account alias1 --admin --profile admin1 --role aws-admin --duration 36000
stskeygen --account alias2 --admin --profile admin2 --role aws-admin --duration 36000

terraform init
terraform plan
terraform apply
