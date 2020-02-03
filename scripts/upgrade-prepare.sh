#!/usr/bin/env bash
if [ $PWD != $HOME ] ; then echo "USAGE: $0 Must be run from $HOME"; exit 1 ; fi

source ~/dell-lab/scripts/0-site-settings.sh

source ~/stackrc
cd ~
time openstack overcloud update prepare --templates \
    --stack $stack_name \
    -p /usr/share/openstack-tripleo-heat-templates/plan-samples/plan-environment-derived-params.yaml \
    -n ~/dell-lab/templates/network_data.yaml \
    -r ~/dell-lab/templates/roles_data.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-environment.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/disable-telemetry.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-sriov.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/ceph-ansible/ceph-ansible.yaml \
    -e ~/dell-lab/templates/environments/storage-config.yaml \
    -e ~/dell-lab/templates/environments/overcloud-images.yaml \
    -e ~/dell-lab/templates/environments/dell-lab-environment.yaml \
    --log-file deployment.log

# now we run the individual role updates, then come back and continue on
exit 0

time openstack overcloud update converge --templates \
    --stack $stack_name \
    -p /usr/share/openstack-tripleo-heat-templates/plan-samples/plan-environment-derived-params.yaml \
    -n ~/dell-lab/templates/network_data.yaml \
    -r ~/dell-lab/templates/roles_data.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-isolation.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/network-environment.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/disable-telemetry.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/neutron-sriov.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/host-config-and-reboot.yaml \
    -e /usr/share/openstack-tripleo-heat-templates/environments/ceph-ansible/ceph-ansible.yaml \
    -e ~/dell-lab/templates/environments/storage-config.yaml \
    -e ~/dell-lab/templates/environments/overcloud-images.yaml \
    -e ~/dell-lab/templates/environments/dell-lab-environment.yaml \
    --log-file deployment.log
