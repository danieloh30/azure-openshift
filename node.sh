#!/bin/bash

# for Subscription Manager
RHSM_USERNAME=$1
RHSM_PASSWD=$2
RHSM_POOLID=$3

#
# subscribe
#
subscription-manager register --username=$RHSM_USERNAME --password=$RHSM_PASSWORD
subscription-manager attach --pool $RHSM_POOLID
subscription-manager repos --disable=*
subscription-manager repos \
         --enable=rhel-7-server-rpms \
         --enable=rhel-7-server-extras-rpms \
         --enable=rhel-7-server-optional-rpms \
         --enable=rhel-7-server-ose-3.1-rpms



#yum -y update
yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion docker-1.8.2 atomic-openshift-utils

sed -i -e "s#^OPTIONS='--selinux-enabled'#OPTIONS='--selinux-enabled --insecure-registry 172.30.0.0/16'#" /etc/sysconfig/docker
                                                                                         
cat <<EOF > /etc/sysconfig/docker-storage-setup
DEVS=/dev/sdc
VG=docker-vg
EOF

docker-storage-setup                                                                                                                                    
systemctl enable docker

