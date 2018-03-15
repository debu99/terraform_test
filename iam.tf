resource "aws_iam_role_policy" "terrform_ec2_role_policy" {
  name = "terrform_ec2_role_policy"
  role = "${aws_iam_role.terrform_ec2_role.id}"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
                "route53:ChangeResourceRecordSets",
                "route53:GetHostedZone",
                "route53:GetChange",
                "route53:ListResourceRecordSets"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}



resource "aws_iam_role" "terrform_ec2_role" {
    name = "terrform_ec2_role"
    assume_role_policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
{
  "Action": "sts:AssumeRole",
  "Principal": {
    "Service": "ec2.amazonaws.com"
  },
  "Effect": "Allow"
}
]
}
EOF
}


resource "aws_iam_instance_profile" "terraform_instance_profile" {
    name = "terraform_instance_profile"
    path = "/"
    role = "${aws_iam_role.terrform_ec2_role.name}"
    depends_on = ["aws_iam_role.terrform_ec2_role"]
}


