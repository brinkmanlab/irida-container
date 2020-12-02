#!/usr/bin/env bash
# This file is only necessary due to https://github.com/hashicorp/terraform/issues/4149

terraform apply -target=module.cloud -auto-approve
terraform apply -target=module.galaxy-storage -auto-approve
terraform apply -target=module.irida-storage -auto-approve
terraform apply -target=module.galaxy -auto-approve
terraform apply -target=module.admin_user -auto-approve
# -parallelism=1 due to https://github.com/galaxyproject/galaxy/issues/10651
terraform apply -target=module.irida -auto-approve -parallelism=1
terraform apply -auto-approve

echo "Run destroy.sh to shutdown and delete everything"