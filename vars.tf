

variable "aws_region" {
    description = "The AWS region to create resources in."
    default = "ap-southeast-1"
}

variable "environment" {
    default = "devops"
}

variable "domainname" {
    default = "test.com"
}

variable "public_key" {
  default = "aws_terraform.pub"
}

resource "aws_key_pair" "public_key" {
  key_name   = "public_key"
  public_key = "${file("${var.public_key}")}"
}


variable "ALLOWED_IPS" {
  type = "map"
  default = {
    all   = "0.0.0.0/0"
    local = "200.200.0.0/16"
    home = "116.14.14.60/32"
  }
}


variable "instance_type" {
    default = "t2.micro"
}

variable "amis" {
    description = "Which AMI to spawn. Defaults to the AWS ECS optimized images."
    # http://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI_launch_latest.html
    default = {
        ap-southeast-1 = "ami-d2fa88ae"
    }
}


data "template_file" "ec2_userdata" {
  template = "${file("./userdata/mongo_userdata.sh.tpl")}"

  vars {
      HOST_ZONE_ID = "${aws_route53_zone.primary.zone_id}"
      MONGO_KEY = "${file("mongodb-keyfile")}"
  }
}

variable "volume_size" {
    default = 10
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "200.200.0.0/16"
}
variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = ["200.200.0.0/24", "200.200.1.0/24","200.200.2.0/24"]
}

variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = ["200.200.100.0/24","200.200.101.0/24","200.200.102.0/24"]
}



data "aws_availability_zones" "available" {}

variable "aws_access_key" {
    description = "The AWS access key."
    default = ""
}

variable "aws_secret_key" {
    description = "The AWS secret key."
    default = ""
}

provider "aws" {
    access_key = "${var.aws_access_key}"
    secret_key = "${var.aws_secret_key}"
    region = "${var.aws_region}"
}