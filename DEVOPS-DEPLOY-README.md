# Ceros Ski DevOps Challenge

Pre-requisites and Steps
———————————-------------
1) Ensure that you already have the AWS CLI, terraform, and Ansible installed and configured on your control machine or development machine.
2) Setup your AWS CLI with your Access key ID and Secret access key. Also add them to the configure_remote_app_node.sh to assign the AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY environment variables.
3) Manually create an Elastic Container Registry (ECR) repository with the name ceros/ski in advance. 
4) Copy the URL of your new ECR repository and replace every occurrence of 519826568739.dkr.ecr.us-east-2.amazonaws.com/ceros/ski:latest in the deploy.sh, blue-green-deploy.sh, and configure_remote_app_node.sh files.
5) Run npm install to download the NodeJS app’s dependencies.
6) Dockerize the Nodejs app by creating a Dockerfile.
7) Create an ssh key pair and copy it from its default location to the directory containing your project’s root directory. It must not be within your project’s root directory but above it for security reasons. Give your private key the appropriate permissions if you have any access issues.
8) Run the deploy.sh script at the root of the application.
	
     ./deploy.sh 

9) Navigate to the http://{AWS_INSTANCE_IP_ADDRESS}:5000/ 

  for example, 
  http://3.17.205.155:5000/

10) To connect to the remote machine, run the following command. Note that your ssh key pair must have been copied to the directory containing your project’s root directory.

ssh -i "../ceros_id_rsa" ubuntu@{AWS_INSTANCE_IP_ADDRESS}

For example, 
ssh -i "../ceros_id_rsa" ubuntu@3.17.205.155

11) Blue/Green deployment: To carry out a deployment without any downtime in a simple way, run the blue-green-deploy.sh script. You must have done a first deployment using deploy.sh for this script to work. This is because the deploy.sh script creates the Terraform backend infrastructure that is a requirement for the main infrastructure to be provisioned.

N.B: YOU DO NOT NEED TO EXECUTE THE STEPS BELOW. THEY ARE RUN BY THE SCRIPTS.

Steps performed by the deploy.sh Script
——————————————————---------------------
1) Run npm install to download the NodeJS app’s dependencies.
2) Perform an AWS login in script.
3) Build and tag the docker image from the Dockerfile that you created earlier.
4) Push the docker image to the ceros/ski ECR registry that you create in the pre-requisites section.
5) Using Terraform, create or provision the resources for maintaining and locking the terraform remote state file, terraform.tfstate. Locking this file is useful in the scenario where you have to work in a team of DevOps engineers on the same project.
6) After prompting the user and the user’s consent, use Terraform to create or provision the desired target server resources where we will deploy our app container.
7) After prompting the user and the user’s consent, use Ansible to configure the servers that have just been provisioned. This installs and configures the prerequisites required by our app container and our app container itself. It pulls the docker image from our ECR registry and runs a container instance from it. It also places an Nginx load balancer in front of the instances.
8) Prompt the user for the permission to destroy the provisioned server resources using Terraform.


Steps performed by the blue-green-deploy.sh Script
——————————————————--------------------------------
1) Run npm install to download the NodeJS app’s dependencies.
2) Perform an AWS login in script.
3) Build and tag the docker image from the Dockerfile that you created earlier.
4) Push the docker image to the ceros/ski ECR registry that you created in the pre-requisites section.
5) Destroy appserver1 using Terraform.
6) Recreate appserver1 with Terraform and configure it with the latest application deployment using Ansible.
7) Reconfigure the Load balancer to pick up appserver1's new IP address.
8) Destroy appserver2 using Terraform.
9) Recreate appserver2 with Terraform and configure it with the latest application deployment using Ansible.
10) Reconfigure the Load balancer to pick up appserver2's new IP address.


Issues and TODOs
----------------
1) The AWS credentials could be made more secure through the use of secrets management tools like Ansible vaults etc.
2) The IP addresses of the appservers and their constituent docker containers have been intentionally left open to the public for this demo's purposes. In the real world I would restrict inbound traffic to the appservers from the load balancer only.
3) The Blue/Green deployment script does not remove the IP addresses of the destroyed appservers from the hosts file. Therefore, you may see Ansible fail to reach those servers before going on to configure the servers that have been newly provisioned by Terraform.