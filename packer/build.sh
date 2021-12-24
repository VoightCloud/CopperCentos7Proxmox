#!/bin/bash

export password=`openssl rand -base64 9`

echo $password
epoch=`date +%s`
export ksisoname="ks-proxmox-${epoch}.iso"
export templateName="copper-centos7-${epoch}"
hash=`openssl passwd -6 $password`

sed -i -E "s|\-\-password=(.*)|--password=$hash|g" http/ks-proxmox.cfg
mkisofs -o "${ksisoname}" http
export ksisochecksum=`sha256sum ${ksisoname}|awk '{print $1}'`
packer init proxmox.pkr.hcl
packer build --force proxmox.pkr.hcl
rm -f "${ksisoname}"
sed -i -E "s|\-\-password=(.*)|--password=randpass|g" http/ks-proxmox.cfg
