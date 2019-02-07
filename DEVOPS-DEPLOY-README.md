# Ceros Ski DevOps Challenge

Pre-requisites and Steps
———————————
1) Ensure that you already have the AWS CLI, terraform, and Ansible installed and configured on your control machine or development machine.
2) Setup your AWS CLI with your Access key ID and Secret access key.
3) Manually create an ECR repository with the name ceros/ski in advance.
4) Run npm install to download the NodeJS app’s dependencies.
5) Dockerize the Nodejs app by creating a Dockerfile.
6) Create an ssh key pair and copy it from its default location to the directory containing your project’s root directory. It must not be within your project’s root directory but above it for security reasons.
7) Run the deploy.sh script at the root of the application.
	
     ./deploy.sh 

8) Navigate to the http://{AWS_INSTANCE_IP_ADDRESS}:5000/ 

  for example, 
  http://3.17.205.155:5000/

9) To connect to the remote machine, run the following command. Note that your ssh key pair must have been copied to the directory containing your project’s root directory.

ssh -i "../ceros_id_rsa" ubuntu@{AWS_INSTANCE_IP_ADDRESS}

For example, 
ssh -i "../ceros_id_rsa" ubuntu@3.17.205.155

Steps performed by the deploy.sh Script
——————————————————
1) Run npm install to download the NodeJS app’s dependencies.
2) Perform an AWS login in script.
3) Build and tag the docker image from the Dockerfile that you created earlier.
4) Push the docker image to the ceros/ski ECR registry that you create in the pre-requisites section.
5) Using Terraform, create or provision the resources for maintaining and locking the terraform remote state file, terraform.tfstate. Locking this file is useful in the scenario where you have to work in a team of DevOps engineers on the same project.
6) After prompting the user and the user’s consent, use Terraform to create or provision the desired target server resources where we will deploy our app container.
7) After prompting the user and the user’s consent, use Ansible to configure the servers that have just been provisioned. This installs and configures the prerequisites required by our app container and our app container itself. It pulls the docker image from our ECR registry and runs a container instance from it.
8) Prompt the user for the permission to destroy the provisioned server resources using Terraform.