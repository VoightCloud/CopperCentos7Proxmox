#!/bin/bash

set -e -x
# Enable DNS -- AWS, ADEX, NOC
# sudo nmcli con mod enp0s3 ipv4.dns "10.168.88.2 10.168.62.24 10.48.69.84"
# Add sudoers file and cloud.cfg
echo "$DNA" >> /home/centos/dna.txt
sudo cp /home/centos/dna.txt /etc/dna.txt
sudo cp /home/centos/sudoers /etc/
sudo cp /home/centos/cloud.cfg /etc/cloud
# Restart Network Manager
sudo systemctl restart NetworkManager.service

# Install required certificates
sudo cp /home/centos/voight-ca.pem /etc/pki/ca-trust/source/anchors/voight-ca.pem
sudo update-ca-trust extract

## * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
## For an air-gapped environment, uncomment the following block
#if [[ -f /etc/yum/pluginconf.d/fastestmirror.conf ]]; then
#  # Disable fastest mirror because VPN blocks it
#  sudo sed -i 's/enabled=1/enabled=0/g' /etc/yum/pluginconf.d/fastestmirror.conf
#
#  # Disable Internet repos
#  for file in `ls /etc/yum.repos.d/`; do sudo sed -i 's/enabled=1/enabled=0/g' "/etc/yum.repos.d/$file"; done
#  sudo sed -i '/gpgcheck.*/a enabled=0' /etc/yum.repos.d/CentOS-Base.repo
#  sudo sed -i '/enabled=0/enabled=1/g' /etc/yum.repos.d/CentOS-Media.repo
#
#fi
## * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

# Install pip, and ansible
sudo pip3 install --upgrade pip
sudo pip3 install wheel
sudo pip3 install selinux
sudo pip3 install ansible

