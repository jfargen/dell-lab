#!/usr/bin/env bash
# This script should be run as the stack user on the undercloud

source ~/dell-lab/scripts/0-site-settings.sh
source /home/stack/stackrc

cd ~/images
cp -f overcloud-full.qcow2 overcloud-realtime-compute.qcow2

# CDN
echo "enter cdn password: "
read CDNPASS
virt-customize -a overcloud-realtime-compute.qcow2 --run-command \
"subscription-manager register --username=$cdn_user --password=$CDNPASS" \
--run-command "subscription-manager attach --pool $pool"

# Satellite
#virt-customize -a overcloud-realtime-compute.qcow2 \
#--run-command "yum localinstall -y http://$satellite/pub/katello-ca-consumer-latest.noarch.rpm" \
#--run-command "subscription-manager register --name tempvm.lab.roskosb.info --org $org --activationkey $director_activation_key --force"

virt-customize -a overcloud-realtime-compute.qcow2 -v \
--copy-in ~/i40e-2.10.19.30-1.x86_64.rpm:/root/ \
--run ~/dell-lab/scripts/rt.sh 2>&1 | tee ~/virt-customize.log

# now that the new kernel is installed we can install the upstream i40e driver
# Temporary, until we have a rhel 7.8 image
virt-customize -a overcloud-realtime-compute.qcow2 -v \
--copy-in ~/i40e-2.10.19.30-1.x86_64.rpm:/root/ \
--copy-in ~/fpga-drivers-1.0-1.el7.x86_64.rpm:/root/ \
--run-command "yum localinstall -y /root/fpga-drivers-1.0-1.el7.x86_64.rpm" \
--run-command 'cat << EOF >>  /etc/rc.local

# manually set snmp_smp_affinity
for i in /proc/irq/*/smp_affinity; do
 echo 00000030,00000003 > $i 2>/dev/null
done

if rpm -q i40e-2.10.19.30-1.x86_64 > /dev/null;then
 echo "rpm present"
else
 echo "install rpm"
 yum localinstall -y /root/i40e-2.10.19.30-1.x86_64.rpm
fi

EOF'

virt-customize -a overcloud-realtime-compute.qcow2 --selinux-relabel

#############################
# extract vmliuz and initrd #
#############################
rm -Rf /var/tmp/.guestfs*
mkdir -p ~/images/rt-image
guestmount -a overcloud-realtime-compute.qcow2 -i --ro rt-image
cp rt-image/boot/vmlinuz-*.rt56.1033.el7.x86_64 ./overcloud-realtime-compute.vmlinuz
cp rt-image/boot/initramfs-*.rt56.1033.el7.x86_64.img ./overcloud-realtime-compute.initrd
guestunmount rt-image
rm -Rf ~/images/rt-image

###########################
# Upload Images to Glance #
###########################
openstack overcloud image upload --image-path /home/stack/images/ \
--update-existing --os-image-name overcloud-realtime-compute.qcow2