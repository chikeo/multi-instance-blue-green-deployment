#!/usr/bin/env bash
# Author: Chikelue Oji
 
 # NOTE: A first deployment should have already been done using the deploy.sh script for this script to work.
 # This first deployment using the deploy.sh script would have setup resources such as the Terraform backend resources.
 # This script will destroy one server and create it while the load balancer keeps routing traffic to the remaining server.

echo "------------------------------------------------------------------------------------"
echo " Perfom a Blue/Green deployment of the application                                  "
echo "------------------------------------------------------------------------------------"

ROOT_DIR=$PWD
export ANSIBLE_HOST_KEY_CHECKING=False

ansible_configure_appserver1() {
echo "Waiting for 300 seconds to allow for the EC2 machine to be fully provisioned and to come online"
sleep 300

ansible-playbook -i $ROOT_DIR/ansible/hosts --limit ceros-ski-appserver1 $ROOT_DIR/ansible/main.yml -e 'ansible_python_interpreter=/usr/bin/python3'

}

ansible_configure_appserver2() {
echo "Waiting for 300 seconds to allow for the EC2 machine to be fully provisioned and to come online"
sleep 300

ansible-playbook -i $ROOT_DIR/ansible/hosts --limit ceros-ski-appserver2 $ROOT_DIR/ansible/main.yml -e 'ansible_python_interpreter=/usr/bin/python3'

}

echo "-----------------------------------------------------------------------"
echo " Dockerize the Ceros Ski NodeJS app and push to ECR Container Registry "
echo "-----------------------------------------------------------------------"

npm install

$(aws ecr get-login --no-include-email --region us-east-2)

docker build -t ceros/ski .

docker tag ceros/ski:latest 519826568739.dkr.ecr.us-east-2.amazonaws.com/ceros/ski:latest

docker push 519826568739.dkr.ecr.us-east-2.amazonaws.com/ceros/ski:latest

# Change directory to the main infrastructure terraform directory
cd $ROOT_DIR/terraform

# Initialise Terraform
terraform init

# Destroy application server 1 EC2 instance named ceros-ski-appserver1
echo "yes" | terraform destroy -target aws_instance.ceros-ski-appserver1

# Create/Deploy/Apply application server 1 EC2 instance named ceros-ski-appserver1
echo "yes" | terraform apply -target aws_instance.ceros-ski-appserver1

while true; do
    read -p "Do you wish to proceed with the server configuration of ceros-ski-appserver1? " yn
    case $yn in
        [Yy]* ) ansible_configure_appserver1; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Reconfigure the Load balancer to pick up ceros-ski-appserver1's new IP address.
ansible-playbook -i $ROOT_DIR/ansible/hosts $ROOT_DIR/ansible/main.yml -e 'ansible_python_interpreter=/usr/bin/python3' --tags "nginx"

# Destroy application server 2 EC2 instance named ceros-ski-appserver2
echo "yes" | terraform destroy -target aws_instance.ceros-ski-appserver2

# Create/Deploy/Apply application server 2 EC2 instance named ceros-ski-appserver2
echo "yes" | terraform apply -target aws_instance.ceros-ski-appserver2

while true; do
    read -p "Do you wish to proceed with the server configuration of ceros-ski-appserver2? " yn
    case $yn in
        [Yy]* ) ansible_configure_appserver2; break;;
        [Nn]* ) break;;
        * ) echo "Please answer yes or no.";;
    esac
done

# Reconfigure the Load balancer to pick up ceros-ski-appserver2's new IP address.
ansible-playbook -i $ROOT_DIR/ansible/hosts $ROOT_DIR/ansible/main.yml -e 'ansible_python_interpreter=/usr/bin/python3' --tags "nginx"

echo "Blue/Green Deployment complete!"