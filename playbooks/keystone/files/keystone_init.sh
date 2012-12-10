#!/bin/bash

function get_id () {
    echo `"$@" | grep ' id ' | awk '{print $4}'`
}

export SERVICE_TOKEN={{ admin_token }}
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD={{ default_admin_password }}
export OS_AUTH_URL=http://127.0.0.1:5000/v2.0/
export SERVICE_ENDPOINT=http://127.0.0.1:35357/v2.0/
PUBLIC_IP={{ controller_public_ip }}
PRIVATE_IP={{ controller_private_ip }}
REGION=litestack

ADMIN_USER=$(get_id keystone user-create --name admin --pass $OS_PASSWORD --email admin@litestack.com)
NOVA_USER=$(get_id keystone user-create --name nova --pass $OS_PASSWORD --email nova@litestack.com)
GLANCE_USER=$(get_id keystone user-create --name glance --pass $OS_PASSWORD --email glance@litestack.com)
SWIFT_USER=$(get_id keystone user-create --name swift --pass $OS_PASSWORD --email swift@litestack.com)
CINDER_USER=$(get_id keystone user-create --name cinder --pass $OS_PASSWORD --email cinder@litestack.com)
#QUANTUM_USER=$(get_id keystone user-create --name quantum --pass $OS_PASSWORD --email quantum@litestack.com)

ADMIN_ROLE=$(get_id keystone role-create --name admin)
MEMBER_ROLE=$(get_id keystone role-create --name Member)

SERVICE_TENANT=$(get_id keystone tenant-create --name=service)
ADMIN_TENANT=$(get_id keystone tenant-create --name=admin)

NOVA_SERVICE=$(get_id keystone service-create --name nova --type compute --description "OpenStack Compute Service")
VOLUME_SERVICE=$(get_id keystone service-create --name volume --type volume --description "OpenStack Volume Service")
GLANCE_SERVICE=$(get_id keystone service-create --name glance --type image --description "OpenStack Image Service")
SWIFT_SERVICE=$(get_id keystone service-create --name swift --type object-store --description "OpenStack Storage Service")
KEYSTONE_SERVICE=$(get_id keystone service-create --name keystone --type identity --description "OpenStack Identity Service")
EC2_SERVICE=$(get_id keystone service-create --name ec2 --type ec2 --description "EC2 Service")
CINDER_SERVICE=$(get_id keystone service-create --name cinder --type volume --description "Cinder Service")
#QUANTUM_SERVICE=$(get_id keystone service-create --name quantum --type network --description "OpenStack Networking service")

keystone endpoint-create --region $REGION --service_id $NOVA_SERVICE --publicurl "http://$PUBLIC_IP:8774/v2/%(tenant_id)s" --adminurl "http://$PRIVATE_IP:8774/v2/%(tenant_id)s" --internalurl "http://$PRIVATE_IP:8774/v2/%(tenant_id)s"
keystone endpoint-create --region $REGION --service_id $VOLUME_SERVICE --publicurl "http://$PUBLIC_IP:8776/v1/%(tenant_id)s" --adminurl "http://$PRIVATE_IP:8776/v1/%(tenant_id)s" --internalurl "http://$PRIVATE_IP:8776/v1/%(tenant_id)s"
keystone endpoint-create --region $REGION --service_id $GLANCE_SERVICE --publicurl "http://$PRIVATE_IP:9292/v1" --adminurl "http://$PRIVATE_IP:9292/v1" --internalurl "http://$PRIVATE_IP:9292/v1"
keystone endpoint-create --region $REGION --service_id $SWIFT_SERVICE --publicurl "http://$PUBLIC_IP:8080/v1/AUTH_%(tenant_id)s" --adminurl "http://$PRIVATE_IP:8080/v1" --internalurl "http://$PRIVATE_IP:8080/v1/AUTH_%(tenant_id)s"
keystone endpoint-create --region $REGION --service_id $KEYSTONE_SERVICE --publicurl "http://$PUBLIC_IP:5000/v2.0" --adminurl "http://$PRIVATE_IP:35357/v2.0" --internalurl "http://$PRIVATE_IP:5000/v2.0"
keystone endpoint-create --region $REGION --service_id $EC2_SERVICE --publicurl "http://$PUBLIC_IP:8773/services/Cloud" --adminurl "http://$PRIVATE_IP:8773/services/Admin" --internalurl "http://$PRIVATE_IP:8773/services/Cloud"
keystone endpoint-create --region $REGION --service_id $CINDER_SERVICE --publicurl "http://$PUBLIC_IP:8776/v1/%(tenant_id)s" --adminurl "http://$PRIVATE_IP:8776/v1/%(tenant_id)s" --internalurl "http://$PRIVATE_IP:8776/v1/%(tenant_id)s"
#keystone endpoint-create --region $REGION --service-id $QUANTUM_SERVICE --publicurl "http://$PUBLIC_IP:9696/v2" --adminurl "http://$PRIVATE_IP:9696/v2" --internalurl "http://$PRIVATE_IP:9696/v2"

keystone user-role-add --user_id $ADMIN_USER --role_id $ADMIN_ROLE --tenant_id $ADMIN_TENANT

keystone user-role-add --user_id $NOVA_USER --role_id $ADMIN_ROLE --tenant_id $SERVICE_TENANT
keystone user-role-add --user_id $GLANCE_USER --role_id $ADMIN_ROLE --tenant_id $SERVICE_TENANT
keystone user-role-add --user_id $SWIFT_USER --role_id $ADMIN_ROLE --tenant_id $SERVICE_TENANT
keystone user-role-add --user_id $CINDER_USER --role_id $ADMIN_ROLE --tenant_id $SERVICE_TENANT
#keystone user-role-add --user_id $QUANTUM_USER --role_id $ADMIN_ROLE --tenant_id $SERVICE_TENANT

keystone user-role-add --user_id $ADMIN_USER --role_id $MEMBER_ROLE --tenant_id $ADMIN_TENANT
keystone user-role-add --user_id $SWIFT_USER --role_id $MEMBER_ROLE --tenant_id $SERVICE_TENANT

