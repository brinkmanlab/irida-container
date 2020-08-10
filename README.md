# IRIDA Container and deployment

## Build

To build the containers, ensure you have buildah, docker, terraform, and ansible-playbook installed and configured.
Ensure docker can be [run without root privledges](https://docs.docker.com/engine/install/linux-postinstall/).

Run `./webserver.playbook.yml` and `./application.playbook.yml` to build the containers.

## Run local
If you do not build the containers, they will be pulled from docker hub automatically.
Run `./buildah_to_docker.sh` to push the built containers to your local docker instance for testing.
Or modify `./changeme.auto.tfvars` to refer to the most recent image tag to pull from docker hub.

Run the following to start an instance on your local computer using docker:
```shell script
terraform init
terraform plan  # Ensure the plan shows no errors
terraform apply  # Ensure apply ran without error
```

To shut down this instance, run `terraform destroy`. This will delete the instance, all of its data, and the images
pushed to docker.

## Deploy to cloud

Several terraform destinations have been configured. Select one from the `./destinations/` folder that you wish to use.
Modify `./main.tf` to refer to that destination and provide any necessary provider configuration.
Currently terraform does not support optional providers and so this has to be a manual process.


### AWS

After running `terraform apply` it generates a kubeconfig file allowing you to run kubectl commands on the kubernetes cluster.
Install kubectl, aws-iam-authenticator, and `export KUBECONFIG=./kubeconfig_irida-cluster`. Run `kubectl proxy`.
`kubectl apply --kubeconfig kubeconfig_irida-cluster -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.3/aio/deploy/recommended.yaml`
Visit [](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/) to
access the dashboard. The `kubeconfig_irida-cluster` file does not include the 
[token required for authentication](https://github.com/kubernetes/dashboard/issues/2474#issuecomment-348811806). 
Run `aws-iam-authenticator token -i irida-cluster --token-only` to get the required token.

### Kubernetes

To check the state of the cluster run `kubectl describe node --kubeconfig kubeconfig_irida-cluster`.



### Azure

### Existing Kubernetes cluster

### Existing Nomad cluster

## Project layout

### Container generation



### Deployment