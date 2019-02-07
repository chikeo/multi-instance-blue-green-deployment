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

resource "aws_key_pair" "ceros_id_rsa" {
  key_name   = "ceros_id_rsa"
  public_key = "${file("${var.PATH_TO_PUBLIC_KEY}")}"
}

resource "aws_instance" "ubuntu" {
  ami                    = "${lookup(var.AMI_ID, var.AWS_REGION)}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.ceros_id_rsa.key_name}"
  vpc_security_group_ids = ["${aws_security_group.ceros-allow-inbound-ssh.id}", "${aws_security_group.ceros-allow-outbound-internet.id}", "${aws_security_group.ceros-allow-inbound-app.id}"]

  tags {
    Name = "Ubuntu-16.04"
  }

  provisioner "local-exec" {
    command = "echo \"[ceros-ski-server]\n${aws_instance.ubuntu.public_ip} ansible_connection=ssh ansible_ssh_user=ubuntu\"  > ../ansible/hosts"
  }
}
