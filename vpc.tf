
#Define a VPC
resource "aws_vpc" "test_vpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    enable_dns_support = true
    tags {
      Name = "VPC-${var.environment}"
      Environment = "${var.environment}"
    }
}

resource "aws_subnet" "sub_pub" {
    count = "${length(data.aws_availability_zones.available.names)}"
    vpc_id = "${aws_vpc.test_vpc.id}"
    #cidr_block = "${var.public_subnet_cidr}"
    cidr_block = "${element(var.public_subnet_cidr,count.index)}"
    #availability_zone = "${var.availability_zone}"

    availability_zone = "${element(data.aws_availability_zones.available.names,count.index)}"

    tags {
      Name = "Public Subnet ${count.index}"
      Environment = "${var.environment}"
    }
}


#Internet gateway for the public subnet
resource "aws_internet_gateway" "vpc_ig" {
    vpc_id = "${aws_vpc.test_vpc.id}"
    tags {
      Name = "Internet Gateway"
      Environment = "${var.environment}"
    }
}

#Routing table for public subnet
resource "aws_route_table" "rt_pub" {
    vpc_id = "${aws_vpc.test_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.vpc_ig.id}"
    }
    tags {
      Name = "RT for pub subnet"
      Environment = "${var.environment}"
    }
}

resource "aws_route_table_association" "sub_pub_with_rt" {
    #count = "${length(var.availability_zone)}"
    count = "${length(data.aws_availability_zones.available.names)}"
    subnet_id = "${element(aws_subnet.sub_pub.*.id,count.index)}"
    route_table_id = "${aws_route_table.rt_pub.id}"
}






resource "aws_subnet" "sub_prv" {
    #count = "${length(var.availability_zone)}"
    count = "${length(data.aws_availability_zones.available.names)}"
    vpc_id = "${aws_vpc.test_vpc.id}"
    #cidr_block = "${var.public_subnet_cidr}"
    cidr_block = "${element(var.private_subnet_cidr,count.index)}"
    #availability_zone = "${var.availability_zone}"
    #availability_zone = "${element(var.availability_zone,count.index)}"
    availability_zone = "${element(data.aws_availability_zones.available.names,count.index)}"
    map_public_ip_on_launch = false
    tags {
      Name = "Private Subnet ${count.index}"
      Environment = "${var.environment}"
    }
}

resource "aws_route_table" "rt_prv" {
    vpc_id = "${aws_vpc.test_vpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        #gateway_id = "${aws_internet_gateway.vpc_ig.id}"
        nat_gateway_id = "${aws_nat_gateway.nat.id}"
    }
    tags {
      Name = "RT for Private Subnet"
      Environment = "${var.environment}"
    }
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_route_table_association" "sub_prv_with_rt" {
    #count = "${length(var.availability_zone)}"
    count = "${length(data.aws_availability_zones.available.names)}"
    subnet_id = "${element(aws_subnet.sub_prv.*.id,count.index)}"
    route_table_id = "${aws_route_table.rt_prv.id}"
}


resource "aws_eip" "nat" {
    vpc = true
    lifecycle {
      create_before_destroy = true
    }
    tags {
      Name = "EIP for NAT"
      Environment = "${var.environment}"
    }
}

resource "aws_nat_gateway" "nat" {
    allocation_id = "${aws_eip.nat.id}"
    subnet_id     = "${element(aws_subnet.sub_pub.*.id, 0)}"
    depends_on    = ["aws_internet_gateway.vpc_ig"]
    lifecycle {
      create_before_destroy = true
    }
    tags {
      Name = "NAT for Private Subnet"
      Environment = "${var.environment}"
    }
}


/*
resource "aws_default_network_acl" "default_nacl" {

  default_network_acl_id = "${aws_vpc.test_vpc.default_network_acl_id}"
  subnet_ids = ["${aws_subnet.sub_pub.*.id}", "${aws_subnet.sub_prv.*.id}"]

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}
*/


/*
resource "aws_network_acl" "acl" {
  vpc_id     = "${aws_vpc.vpc.id}"
  subnet_ids = ["${aws_subnet.sub_pub.*.id}", "${aws_subnet.sub_prv.*.id}"]

  ingress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = "-1"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat.id}"
  subnet_id     = "${element(aws_subnet.sub_pub.*.id, 0)}"
  depends_on    = ["aws_internet_gateway.vpc_ig"]
}



*/

