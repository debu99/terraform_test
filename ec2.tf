
resource "aws_instance" "bastion" {
  ami                         = "${lookup(var.amis, var.aws_region)}"
  instance_type               = "${var.instance_type}"
  vpc_security_group_ids      = ["${aws_security_group.ssh.id}"]
  subnet_id                   = "${element(aws_subnet.sub_pub.*.id, 1)}"
  key_name                    = "${aws_key_pair.public_key.key_name}"
  #user_data                   = "${file("./user-data/bastion_cloud_config.yml")}"
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 10
  }

  tags {
    Name = "bastion"
    Environment = "${var.environment}"
  }
}

resource "aws_eip" "bastion_eip" {
  vpc      = true
  instance = "${aws_instance.bastion.id}"
}





resource "aws_instance" "mongo" {
  count = 3
  ami = "${lookup(var.amis, var.aws_region)}"
  key_name = "${var.key_name}"
  instance_type = "${var.instance_type}"
  subnet_id = "${element(aws_subnet.sub_prv.*.id, count.index)}"
  availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
  key_name = "${aws_key_pair.public_key.key_name}"
  vpc_security_group_ids = ["${aws_security_group.ssh.id}","${aws_security_group.mongodb.id}"]
  iam_instance_profile = "${aws_iam_instance_profile.terraform_instance_profile.name}"
  user_data = "${replace(data.template_file.ec2_userdata.rendered, "#DNS_NAME", "mongo${count.index}.${aws_route53_zone.primary.name}")}"
  #user_data = "${var.user_data}"
/*
  root_block_device {
      volume_type = "gp2"
      volume_size = "100"
  }
*/

  tags {
    Name = "mongo-${count.index}"
    Environment = "${var.environment}"
  }

}


resource "aws_ebs_volume" "ebs-volume" {
    count = 3
    availability_zone = "${element(data.aws_availability_zones.available.names, count.index)}"
    size = "${var.volume_size}"
    type = "gp2"
    tags {
      Environment = "${var.environment}"
      Name = "ebs-volume-${count.index}"
    }
}


resource "aws_volume_attachment" "ebs-volume-attachment" {
  count = 3
  device_name = "/dev/sdf"
  volume_id = "${element(aws_ebs_volume.ebs-volume.*.id, count.index)}"
  instance_id = "${element(aws_instance.mongo.*.id, count.index)}"
  skip_destroy = true
}


