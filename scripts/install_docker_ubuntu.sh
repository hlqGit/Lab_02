#!/usr/bin/env bash
set -euxo pipefail

# ensure that package manager interactions are non-interactive
export DEBIAN_FRONTEND=noninteractive

# update and install packages required for adding https repositories
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg

# add docker's gpg key for the repository
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# set up docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# update and install docker engine and some plugins
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# add the current user to the docker group
sudo usermod -aG docker "${SUDO_USER:-$USER}"

# enable and start docker
sudo systemctl enable --now docker