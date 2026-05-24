#!/bin/bash
set -ex

# Install K3s agent (worker node)
curl -sfL https://get.k3s.io | INSTALL_K3S_CHANNEL=${INSTALL_K3S_CHANNEL:-stable} K3S_URL=${K3S_URL} K3S_TOKEN=${K3S_TOKEN} sh -

echo "K3s worker installation complete"
