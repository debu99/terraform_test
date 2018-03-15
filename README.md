--------------------------------------------------------------------
VPC/Architecture
--------------------------------------------------------------------
DevOps(Internet)->Bastion server(AWS Public subnet)->MongoDB servers(AWS Private subnet)

MongoDB->NAT->InternetGW->INTERNET

--------------------------------------------------------------------
Security Group
--------------------------------------------------------------------
Bastion server TCP 22 only open to specific IP address on the Internet
Mongodb Port TCP 27017-27019 open to the VPC subnet

--------------------------------------------------------------------
File lists
--------------------------------------------------------------------
aws_terraform:                          private key
aws_terraform.pub                       public key
*.tf                                    terraform files
/userdata/mongo_userdata.sh.tpl         userdata template file for terraform
mongodb-keyfile                         mongodb keyfile, generated by openssl (openssl rand -base64 741 > mongodb-keyfile)
replica.js                              mongodb replication config file
createcluster.sh                        shell script to execute remote command

--------------------------------------------------------------------
For different environments
--------------------------------------------------------------------
need change variables in vars.tf, variables include AMI, IP Subnet, Region, Domain name, Volume size etc.

--------------------------------------------------------------------
Command
--------------------------------------------------------------------
terraform plan
terraform apply
chmod +x ./createcluster.sh
./createcluster.sh

--------------------------------------------------------------------
CentOS
--------------------------------------------------------------------
1. extra volume mount at /data automatically via /etc/fstab
2. instance will update it's private ip to route53 domainname when bootup

--------------------------------------------------------------------
MongoDB
--------------------------------------------------------------------
1. MongoDB starts as systemd service
2. MongoDB data in /data/db/, logfile in /data/log/


--------------------------------------------------------------------
Todo
--------------------------------------------------------------------
1. Servers' TCP22 only open to Bastion Server
2. Should add one more VPC as management VPC to connect to the Bastion in Production
3. MongoDB is not production setup, need some time to do further research

