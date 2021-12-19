#!/bin/bash

set -e

# Cleanup network devices
echo "Cleaning up network devices"
sudo rm -f /etc/edev/rules.d/70-persistent-net.rules
sudo find /var/lib/dhclient -type f -exec rm -f '{}' +

# Remove hostname
echo "Clearing out /etc/hostname"
sudo tee /etc/hostname <<'EOF'

EOF

# Tune Linux vm.dirty_background_bytes
# Maximum amount of system memory that can be filled with dirty pages before everything must get committed to disk.
echo "Setting vm.dirty_background_bytes"
sudo tee -a /etc/sysctl.conf <<'EOF'
vm.dirty_background_bytes=100000000
EOF

# Cleanup files
echo "Cleaning up build files"
sudo rm -rf /root/anaconda-ks.config
sudo rm -rf /tmp/ks-scripts*
sudo rm -rf /tmp/*.yaml
sudo rm -rf /tmp/*.txt
sudo rm -rf /tmp/*.pub
sudo rm -rf /tmp/*.pem
sudo rm -rf /tmp/*.repo
sudo rm -rf /var/log/anaconda
sudo rm -rf /tmp/*.cfg
#sudo yum clean all

echo '==> Zeroing out empty area to save space in the final image'
set +e
sudo dd if=/dev/zero of=/EMPTY bs=1M
sudo rm -f /EMPTY
sudo dd if=/dev/zero of=/home/EMPTY bs=1M
sudo rm -f /home/EMPTY
sudo dd if=/dev/zero of=/tmp/EMPTY bs=1M
sudo rm -f /tmp/EMPTY
sudo dd if=/dev/zero of=/var/tmp/EMPTY bs=1M
sudo rm -f /var/tmp/EMPTY
sudo dd if=/dev/zero of=/var/EMPTY bs=1M
sudo rm -f /var/EMPTY
sudo dd if=/dev/zero of=/var/log/audit/EMPTY bs=1M
sudo rm -f /var/log/audit/EMPTY

echo "Completed space saving for final image"
