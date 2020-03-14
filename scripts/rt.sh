#!/bin/bash

set -eux

subscription-manager repos --disable '*'
subscription-manager repos \
--enable=rhel-7-server-nfv-rpms \
--enable=rhel-7-server-rpms \
--enable=rhel-7-server-rh-common-rpms \
--enable=rhel-7-server-extras-rpms \
--enable=rhel-7-server-openstack-13-rpms
yum -v -y --setopt=protected_packages= erase kernel.$(uname -m)
yum -v -y install kernel-rt kernel-rt-kvm kernel-rt-devel tuned-profiles-nfv-host
subscription-manager unregister
subscription-manager clean


