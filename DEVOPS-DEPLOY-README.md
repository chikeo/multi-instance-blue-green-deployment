# Ceros Ski DevOps Challenge

Pre-requisites
——————--------
1) Ensure that you already have the AWS CLI, terraform, and Ansible installed and configured on your control machine or development machine.
2) Setup your AWS CLI with your Access key ID and Secret access key.
2) Manually create an ECR repository with the name ceros/ski in advance.

Steps
———--
1) Run npm install to download the NodeJS app’s dependencies.
2) Dockerize the Nodejs app by creating a Dockerfile.
3) Perform an AWS login in script.
4) Build the docker image from the Dockerfile that you created earlier.
5) Push the docker image to the ceros/ski ECR registry that you create in the pre-requisites section.
6) Using Terraform, create or provision the resources for maintaining and locking the terraform remote state file, terraform.tfstate. Locking this file is useful in the scenario where you have to work in a team of DevOps engineers on the same project.
7) After prompting the user and the user’s consent, use Terraform to create or provision the desired target server resources where we will deploy our app container.
8) After prompting the user and the user’s consent, use Ansible to configure the servers that have just been provisioned. This installs and configures the prerequisites required by our app container and our app container itself. It pulls the docker image from our ECR registry and runs a container instance from it.
9) Prompt the user for the permission to destroy the provisioned server resources using Terraform.

To connect to the remote machine, run the following command. Note that your ssh key must be stored in the directory containing your project’s root directory.

ssh -i "../ceros_id_rsa" ubuntu@18.191.203.177
