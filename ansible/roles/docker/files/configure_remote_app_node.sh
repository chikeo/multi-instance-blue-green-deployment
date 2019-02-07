#!/usr/bin/env bash

echo "------------------------------------------------------------------------------------"
echo " Provisioning Ceros Ski App Nodes to install Docker and allow pulling from AWS ECR  "
echo "------------------------------------------------------------------------------------"

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt-get update

apt-cache policy docker-ce

sudo apt-get install -y docker-ce

# sudo systemctl status docker

curl -O https://bootstrap.pypa.io/get-pip.py

python get-pip.py --user

echo 'export PATH=~/.local/bin:$PATH' >> ~/.bash_profile

cat ~/.bash_profile

source ~/.bash_profile

pip --version

pip install awscli --upgrade --user

aws --version

aws configure

sudo $(aws ecr get-login --no-include-email --region us-east-2)

sudo docker pull 519826568739.dkr.ecr.us-east-2.amazonaws.com/ceros/ski:latest

sudo docker run -d -p 5000:5000 519826568739.dkr.ecr.us-east-2.amazonaws.com/ceros/ski:latest
