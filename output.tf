
output "ec2_instance_address" {
  value = "${aws_instance.mongo.*.private_ip}"
}


output "bastion_address" {
  value = "${aws_eip.bastion_eip.public_ip}"
}