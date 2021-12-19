#!/bin/bash

export password=`openssl rand -base64 9`

echo $password

hash=`openssl passwd -6 $password`

sed -i -E "s|\-\-password=(.*)|--password=$hash|g" http/ks-proxmox.cfg

#packer build --force vb_aws.pkr.hcl
packer build --force proxmox.pkr.hcl

sed -i -E "s|\-\-password=(.*)|--password=randpass|g" http/ks-proxmox.cfg
