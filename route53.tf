
resource "aws_route53_zone" "primary" {
  vpc_id = "${aws_vpc.test_vpc.id}"
  name = "${var.domainname}"
}


resource "aws_route53_record" "mongo" {
  count = 3
  zone_id = "${aws_route53_zone.primary.zone_id}"
  name = "mongo${count.index}.${aws_route53_zone.primary.name}"
  type = "A"
  ttl = "300"
  records = ["127.0.0.1"]
}




