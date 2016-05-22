#!/bin/bash
set -x

USERNAME=$1
PASSWORD=$2
HOSTNAME=$3
NODECOUNT=$4
ROUTEREXTIP=$5


# for Subscription Manager
RHSM_USERNAME=$6
RHSM_PASSWORD=$7
RHSM_POOLID=$8

echo "PARAMETERS"
echo "RHSM_USERNAME=$RHSM_USERNAME"
echo "RHSM_PASSWORD=$RHSM_PASSWORD"
echo "RHSM_POOLID=$RHSM_POOLID"

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

#
# yum install
#
yum update -y
systemctl disable NetworkManager
systemctl stop NetworkManager
yum remove NetworkManager\* -y


yum -y install wget git net-tools bind-utils iptables-services bridge-utils bash-completion atomic-openshift-utils docker-1.8.2


#
# config docker
#
sed -i -e "s#^OPTIONS='--selinux-enabled'#OPTIONS='--selinux-enabled --insecure-registry 172.30.0.0/16'#" /etc/sysconfig/docker
                                                                                         
cat <<EOF > /etc/sysconfig/docker-storage-setup
DEVS=/dev/sdc
VG=docker-vg
EOF

docker-storage-setup                                                                                                                                    
systemctl enable docker
systemctl start docker

#
#
#


cat <<EOF > /etc/ansible/hosts
[OSEv3:children]
masters
nodes

[OSEv3:vars]
ansible_ssh_user=${USERNAME}
ansible_sudo=true
debug_level=2
deployment_type=openshift-enterprise
openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider', 'filename': '/etc/origin/master/htpasswd'}]

#openshift_master_default_subdomain=${ROUTEREXTIP}.xip.io 
osm_default_subdomain=${ROUTEREXTIP}.xip.io 

[masters]
master openshift_public_hostname=${HOSTNAME}

[nodes]
master
node[01:${NODECOUNT}] openshift_node_labels="{'region': 'primary', 'zone': 'default'}"
infranode openshift_node_labels="{'region': 'infra', 'zone': 'default'}"
EOF

mkdir -p /etc/origin/master
sudo htpasswd -cb /etc/origin/master/htpasswd ${USERNAME} ${PASSWORD}


cat <<EOF > /home/${USERNAME}/openshift-install.sh
export ANSIBLE_HOST_KEY_CHECKING=False
ansible-playbook /usr/share/ansible/openshift-ansible/playbooks/byo/config.yml

sudo htpasswd -cb /etc/origin/master/htpasswd joe redhat

oadm policy add-role-to-user system:registry reguser
sudo mkdir -p /registry
oadm registry \
    --selector="region=infra" \
    --config=/etc/origin/master/admin.kubeconfig \
    --credentials=/etc/origin/master/openshift-registry.kubeconfig \
    --images='registry.access.redhat.com/openshift3/ose-${component}:${version}' \
    --replicas=1 \
    --service-account=registry \
    --mount-host=/registry

oadm router \
    --selector="region=infra" \
    --config=/etc/origin/master/admin.kubeconfig \
    --credentials=/etc/origin/master/openshift-router.kubeconfig \
    --images='registry.access.redhat.com/openshift3/ose-${component}:${version}' \
    --replicas=1 \
    --service-account=router

EOF

chmod 755 /home/${USERNAME}/openshift-install.sh
