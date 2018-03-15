

resource "aws_security_group" "icmp" {
  name          = "allow-icmp"
  description   = "Allow icmp traffic"
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.ALLOWED_IPS["home"]}"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.ALLOWED_IPS["local"]}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.ALLOWED_IPS["all"]}"]
  }

  vpc_id = "${aws_vpc.test_vpc.id}"

  tags {
    Name = "icmp"
    Environment = "${var.environment}"
  }
}



resource "aws_security_group" "ssh" {
  name          = "allow-ssh"
  description   = "Allow ssh traffic"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ALLOWED_IPS["home"]}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.ALLOWED_IPS["local"]}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.ALLOWED_IPS["all"]}"]
  }

  vpc_id = "${aws_vpc.test_vpc.id}"

  tags {
    Name = "ssh"
    Environment = "${var.environment}"
  }
}



resource "aws_security_group" "mongodb" {
  name          = "allow-mongodb"
  description   = "Allow mongodb traffic"
  ingress {
    from_port   = 27017
    to_port     = 27019
    protocol    = "tcp"
    cidr_blocks = ["${var.ALLOWED_IPS["home"]}"]
  }

  ingress {
    from_port   = 27017
    to_port     = 27019
    protocol    = "tcp"
    cidr_blocks = ["${var.ALLOWED_IPS["local"]}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.ALLOWED_IPS["all"]}"]
  }

  vpc_id = "${aws_vpc.test_vpc.id}"

  tags {
    Name = "mongodb"
    Environment = "${var.environment}"
  }
}