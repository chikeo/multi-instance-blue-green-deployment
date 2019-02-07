#!/usr/bin/env bash
# Author: Chikelue Oji

echo "------------------------------------------------------------------------------------"
echo " Provisioning Ceros Ski App Nodes to install Docker and allow pulling from AWS ECR  "
echo "------------------------------------------------------------------------------------"

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get update

apt-cache policy docker-ce

sudo apt-get install -y docker-ce

sudo apt install -y awscli

sudo apt install -y python3-pip

# Tried to persist the ENV variable LC_ALL but was not really taking effect on target node. Using transient ENV vars instead.
# echo 'export LC_ALL=C' >> ~/.bash_profile

# cat ~/.bash_profile

# source ~/.bash_profile

# Exported this to sort out Local errors when attempting to run pip3 install --upgrade awscli
export LC_ALL=C

pip3 install --upgrade awscli

aws --version

# Running aws configure from Ansible does not interactively prompt the user for aws credentials. Using ENV vars instead.
# aws configure

# This is insecure but the insecurity can be remedied using Ansible Vault.
export AWS_ACCESS_KEY_ID=AKIAJ3JKFVS3ARN4PZXQ
export AWS_SECRET_ACCESS_KEY=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

sudo $(aws ecr get-login --no-include-email --region us-east-2)

sudo docker pull 519826568739.dkr.ecr.us-east-2.amazonaws.com/ceros/ski:latest

sudo docker run -d -p 5000:5000 519826568739.dkr.ecr.us-east-2.amazonaws.com/ceros/ski:latest
