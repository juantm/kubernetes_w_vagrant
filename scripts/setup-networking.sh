#!/bin/bash
set -ex

# Resolve DNS for K3s nodes
cat >> /etc/hosts <<EOF
192.168.56.10 k3s-master
EOF

for i in $(seq 1 ${NODE_COUNT:-2}); do
  echo "192.168.56.$((10 + i)) k3s-worker-$i" >> /etc/hosts
done

# Enable IP forwarding
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
sysctl -p

echo "Network configuration complete"
