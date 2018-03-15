#!/bin/bash
set -euox pipefail

bastionIP=`terraform output bastion_address`
mongo1=`terraform output -json ec2_instance_address|jq '.value[0]'`
mongo2=`terraform output -json ec2_instance_address|jq '.value[1]'`
mongo3=`terraform output -json ec2_instance_address|jq '.value[2]'`

cat << EOF > ssh_config
Host vincent-bastion
HostName "${bastionIP}"
User centos
IdentityFile ./aws_terraform

Host mongo_1
HostName ${mongo1}
User centos
IdentityFile ./aws_terraform
ForwardAgent yes
ProxyCommand ssh vincent-bastion -W %h:%p


Host mongo_2
HostName ${mongo2}
User centos
IdentityFile ./aws_terraform
ForwardAgent yes
ProxyCommand ssh vincent-bastion -W %h:%p


Host mongo_3
HostName ${mongo3}
User centos
IdentityFile ./aws_terraform
ForwardAgent yes
ProxyCommand ssh vincent-bastion -W %h:%p
EOF


cat << EOF > replica.js
rs.initiate( { _id: "rs1", members: [ { _id: 0, host: "mongo0.test.com:27017" }, { _id: 1, host: "mongo1.test.com:27017" }, { _id: 2, host: "mongo2.test.com:27017" } ] } )
EOF

scp -o StrictHostKeyChecking=no -o ProxyCommand="ssh -i ./aws_terraform -W %h:%p centos@${bastionIP}" -F ./ssh_config *.js mongo_1:/data/configdb/
sssh -o StrictHostKeyChecking=no -o ProxyCommand="ssh -i ./aws_terraform -W %h:%p centos@${bastionIP}" -F ./ssh_config mongo_1 docker exec -i mongodb-cluster bash -c '/usr/bin/mongo --quiet < /data/configdb/replica.js'

ssh -o StrictHostKeyChecking=no -o ProxyCommand="ssh -i ./aws_terraform -W %h:%p centos@${bastionIP}" -F ./ssh_config mongo_1 docker exec mongodb-cluster '/usr/bin/mongo --eval "printjson(rs.status())" --quiet'
ssh -o StrictHostKeyChecking=no -o ProxyCommand="ssh -i ./aws_terraform -W %h:%p centos@${bastionIP}" -F ./ssh_config mongo_2 docker exec mongodb-cluster '/usr/bin/mongo --eval "printjson(rs.status())" --quiet'


