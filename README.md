# IRIDA Container and deployment

The repository contains everything needed to build a container for IRIDA and deploy to a cloud resource.
Example deployments are provided in the `./deployment` folder for various destinations. For production use, it is
recommended to create your own deployment recipe using the terraform modules provided in `./desinations`.

## Run local
Change the current working directory to `./deployment/docker`.
Modify `./changeme.auto.tfvars` with any custom values you like.

Run the following to start an instance on your local computer using docker:
```shell script
terraform init
./deploy.sh
```

Browse to http://localhost:8081/ to access the deployment. If you want to access Galaxy directly, it is assigned a random port.
Run `docker ps` to list the running containers, you should see the galaxy-web container with a port exported on 0.0.0.0.

To shut down this instance, run `./destroy.sh`. This will delete the instance, all of its data, and the container images.

## Deploy to cloud

Several terraform destinations have been configured. Select one from the `./destinations/` folder that you wish to use.
Modify `./changeme.auto.tfvars` with any custom values you like. Ensure you are authenticated with your cloud provider
and that the required environment variables are set for the respective terraform provider.

### AWS

IRIDA is deployed into a AWS EKS cluster. To access the cluster install aws-iam-authenticator.
Run `aws-iam-authenticator token -i irida --token-only` to get the required token for the dashboard.
Refer to the Kubernetes section for the remaining information.

### Azure

### Kubernetes

All cloud deployments include a dashboard server that provides administrative control of the cluster.
To access it, install kubectl and run `kubectl proxy` in a separate terminal.
Visit [here](http://localhost:8001/api/v1/namespaces/kube-system/services/https:dashboard-chart-kubernetes-dashboard:https/proxy/#/login) to
access the dashboard.

To check the state of the cluster run `kubectl describe node --kubeconfig kubeconfig_irida-cluster`.

### Existing Kubernetes cluster

Configure the Kubernetes terraform provider and deploy the `./destinations/k8s` module.

### Existing Nomad cluster

Configure the Nomad terraform provider and deploy the `./destinations/nomad` module.

## Build container
To build the containers, ensure you have buildah, docker, terraform, and ansible-playbook installed and configured.
Ensure docker can be [run without root privileges](https://docs.docker.com/engine/install/linux-postinstall/).

Run `./irida.playbook.yml` to build the container.
Run `./buildah_to_docker.sh` to push the built containers to your local docker instance for testing.

## Project layout

### Container generation

Buildah and ansible are the tools used to generate the containers. The relevant paths are:

* `./roles` - Ansible roles applied to the container
* `./irida.playbook.yml` - Run this to begin building the container
* `./irida` - IRIDA sub repository
* `./buildah_to_*.sh` - Push the built container to the local docker daemon or docker hub
* `./vars.yml` - Various configuration options for the container build process. Also imported by the deployment recipes.

### Deployment

Terraform is used to deploy the various resources needed to run IRIDA to the cloud provider of choice.

* `./destinations` - Terraform modules responsible for deployment into the various providers
* `./deployment` - Usage examples for the destination modules