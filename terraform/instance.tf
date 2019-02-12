resource "aws_security_group" "ceros-allow-inbound-ssh" {
  name        = "ceros-allow-inbound-ssh"
  description = "Ceros security group that allows inbound ssh access"

  # Open up inbound ssh access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ceros-allow-inbound-ssh"
  }
}

resource "aws_security_group" "ceros-allow-outbound-internet" {
  name        = "ceros-allow-outbound-internet"
  description = "Ceros security group that allows outbound internet access"

  # Open up outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ceros-allow-outbound-internet"
  }
}

resource "aws_security_group" "ceros-allow-inbound-app" {
  name        = "ceros-allow-inbound-app"
  description = "Ceros security group that allows inbound traffic to the Ceros Ski app"

  # Allow inbound app access
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ceros-allow-inbound-app"
  }
}

resource "aws_security_group" "ceros-allow-bidirectional-http" {
  name        = "ceros-allow-bidirectional-http"
  description = "Ceros security group that allows bi-directional http traffic to and from the Nginx load balancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "ceros-allow-bidirectional-http"
  }
}

resource "aws_key_pair" "ceros_id_rsa" {
  key_name   = "ceros_id_rsa"
  public_key = "${file("${var.PATH_TO_PUBLIC_KEY}")}"
}

resource "aws_instance" "ceros-ski-appserver1" {
  ami                    = "${lookup(var.AMI_ID, var.AWS_REGION)}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.ceros_id_rsa.key_name}"
  vpc_security_group_ids = ["${aws_security_group.ceros-allow-inbound-ssh.id}", "${aws_security_group.ceros-allow-outbound-internet.id}", "${aws_security_group.ceros-allow-inbound-app.id}"]

  tags {
    Name = "Ceros Ski Appserver 1 Ubuntu-16.04"
  }

  provisioner "local-exec" {
    command = "echo \"[ceros-ski-appserver1]\n${aws_instance.ceros-ski-appserver1.public_ip} ansible_connection=ssh ansible_ssh_user=ubuntu\"  >> ../ansible/hosts; echo \"${aws_instance.ceros-ski-appserver1.public_ip}\"  > ../ansible/ceros-ski-appserver1-hosts"
  }
}

resource "aws_instance" "ceros-ski-appserver2" {
  ami                    = "${lookup(var.AMI_ID, var.AWS_REGION)}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.ceros_id_rsa.key_name}"
  vpc_security_group_ids = ["${aws_security_group.ceros-allow-inbound-ssh.id}", "${aws_security_group.ceros-allow-outbound-internet.id}", "${aws_security_group.ceros-allow-inbound-app.id}"]

  tags {
    Name = "Ceros Ski Appserver 2 Ubuntu-16.04"
  }

  provisioner "local-exec" {
    command = "echo \"[ceros-ski-appserver2]\n${aws_instance.ceros-ski-appserver2.public_ip} ansible_connection=ssh ansible_ssh_user=ubuntu\"  >> ../ansible/hosts; echo \"${aws_instance.ceros-ski-appserver2.public_ip}\"  > ../ansible/ceros-ski-appserver2-hosts"
  }
}

resource "aws_instance" "ceros-ski-loadbalancer" {
  ami                    = "${lookup(var.AMI_ID, var.AWS_REGION)}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.ceros_id_rsa.key_name}"
  vpc_security_group_ids = ["${aws_security_group.ceros-allow-inbound-ssh.id}", "${aws_security_group.ceros-allow-outbound-internet.id}", "${aws_security_group.ceros-allow-bidirectional-http.id}"]

  tags {
    Name = "Ceros Ski Loadbalancer Ubuntu-16.04"
  }

  provisioner "local-exec" {
    command = "echo \"[ceros-ski-loadbalancer]\n${aws_instance.ceros-ski-loadbalancer.public_ip} ansible_connection=ssh ansible_ssh_user=ubuntu\"  >> ../ansible/hosts"
  }
}
