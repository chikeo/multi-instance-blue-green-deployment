variable "AWS_REGION" {
  default = "us-east-2"
}

variable "AMI_ID" {
  type = "map"

  default = {
    us-east-2 = "ami-0782e9ee97725263d"
  }
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "../../ceros_id_rsa"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "../../ceros_id_rsa.pub"
}
