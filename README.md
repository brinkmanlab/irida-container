# IRIDA Container and deployment

The repository contains everything needed to build a container for IRIDA and deploy to a cloud resource.
Example deployments are provided in the `./deployment` folder for various destinations. For production use, it is
recommended to create your own deployment recipe using the terraform modules provided in `./desinations`. Terraform
is the deployment managment software used for all deployment destinations.

To install terraform, check that your systems package manager provides it or download it from [here](https://www.terraform.io/downloads.html).

IRIDAs default username and password is `admin` and `password1` respectively.

See the [module documentation](destinations/README.md) for more information on this deployments capabilities and customisability.

## Run local
See [deployment/docker/](deployment/docker/) for instructions.

## Deploy to cloud

Several terraform destinations have been configured. Select one from the `./deployment/` folder that you wish to use.

### AWS

See [deployment/aws/](deployment/aws/) for instructions.

### Azure

TODO

### Kubernetes

All cloud deployments include a dashboard server that provides administrative control of the cluster.
To access it, [install kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) and run `kubectl proxy` in a separate terminal.
Visit [here](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/login) to
access the dashboard.

To check the state of the cluster run `kubectl describe node`.
To restart a deployment run `kubectl rollout restart -n irida deployment <deployment name>`.

### Existing Kubernetes cluster

Configure the Kubernetes terraform provider and deploy the `./destinations/k8s` module.

### Existing Nomad cluster

Configure the Nomad terraform provider and deploy the `./destinations/nomad` module.

## Build container
To build the containers, ensure you have buildah, docker, terraform, and ansible-playbook installed and configured.
Ensure docker can be [run without root privileges](https://docs.docker.com/engine/install/linux-postinstall/).

You do not need to build the containers to deploy an instance of IRIDA. Rebuilding the container is only needed if you want to
customise them. There are pre-built containers already published to docker hub that work for most use cases.

Run `./irida.playbook.yml` to build the container.
Run `./buildah_to_docker.sh` to push the built containers to your local docker instance for testing.

## Project layout

### Container generation

Buildah and ansible are the tools used to generate the containers. The relevant paths are:

* `./roles` - Ansible roles applied to the container
* `./irida.playbook.yml` - Run this to begin building the container
* `./irida` - IRIDA sub repository, initialise it by running `git submodule update --init`
* `./buildah_to_*.sh` - Push the built container to the local docker daemon or docker hub
* `./vars.yml` - Various configuration options for the container build process. Also imported by the deployment recipes.

### Deployment

Terraform is used to deploy the various resources needed to run IRIDA to the cloud provider of choice.

* `./destinations` - Terraform modules responsible for deployment into the various providers
* `./deployment` - Usage examples for the destination modules
