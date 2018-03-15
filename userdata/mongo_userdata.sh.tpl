#!/bin/bash
# Install Docker
yum update
curl -fsSL https://get.docker.com/ | sh
usermod -aG docker centos
systemctl start docker
systemctl enable docker

private_ipv4=`ip -4 route get 8.8.8.8 | awk {'print $7'} | tr -d '\n'`
echo '{"Comment": "Update DNS record","Changes": [{"Action": "UPSERT","ResourceRecordSet": {"Name": "#DNS_NAME.", "Type": "A","TTL": 300, "ResourceRecords": [{"Value": "'$private_ipv4'" }]}}]}' > /root/change-dns-ip.json

echo "${MONGO_KEY}" > /etc/mongodb-keyfile
chmod 0400 /etc/mongodb-keyfile && chown 999 /etc/mongodb-keyfile

mkfs.ext4 /dev/xvdf
mkdir /data && chmod -R 777 /data
echo "/dev/xvdf /data ext4 defaults 0 0" | tee -a /etc/fstab
mount -a

# Write systemd unit file
cat << EOF > /etc/systemd/system/route53-register.service
[Unit]
Description=route53-register
After=docker.service network-online.target
Requires=docker.service network-online.target

[Service]
TimeoutStartSec=0
RemainAfterExit=yes
ExecStartPre=-/usr/bin/docker pull debu99/coreos_awscli:latest
ExecStart=/usr/bin/docker run --rm -v /root/change-dns-ip.json:/root/change-dns-ip.json -i debu99/coreos_awscli:latest aws route53 change-resource-record-sets --hosted-zone-id ${HOST_ZONE_ID} --change-batch file:///root/change-dns-ip.json

[Install]
WantedBy=multi-user.target
EOF


# Write systemd unit file
cat << EOF > /etc/systemd/system/mongo.service
[Unit]
Description=mongo
After=docker.service network-online.target route53-register.service
Requires=docker.service network-online.target
RequiresMountsFor=/data

[Service]
TimeoutStartSec=900s
Restart=always
ExecStartPre=/usr/bin/chmod -R 777 /data
ExecStartPre=/usr/bin/docker pull mongo
ExecStartPre=-/usr/bin/docker stop mongodb
ExecStartPre=-/usr/bin/docker rm -f mongodb
ExecStart=/usr/bin/docker run -d --net=host --user mongodb -p 27017-27019:27017-27019 --name mongodb-cluster --volume=/data/db:/data/db --volume=/data/configdb:/data/configdb --volume=/data/log:/var/log/mongodb --volume=/etc/mongodb-keyfile:/etc/mongodb-keyfile mongo:3.4 --logpath /var/log/mongodb/mongodb.log --keyFile /etc/mongodb-keyfile --replSet 'rs1'

[Install]
WantedBy=multi-user.target
EOF

systemctl start route53-register.service
systemctl enable route53-register.service
systemctl start mongo.service
systemctl enable mongo.service





