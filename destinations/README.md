# Terraform Destination Recipes

This folder contains deployment recipes for various destinations. See the relevant sub-folder for a specific destination.

Some destinations will reference others, for example the `aws` destination only configures resources specific to AWS and then calls out to the `k8s`
destination module to configure the remaining resources.

All destinations symlink the `outputs.tf` and `variables.tf` as `common_output.tf` and `common_variables.tf` respectively. These files contain inputs
and outputs common to all destinations, and will be forwarded to sub-destinations, possibly modifying the values in-between.