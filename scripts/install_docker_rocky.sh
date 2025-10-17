#!/usr/bin/env bash
set -euxo pipefail

# install packages necessary for adding repositories
sudo dnf -y install dnf-plugins-core

# add official docker repo
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# install docker engine and some plugins
sudo dnf -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# add the current user to the docker group
sudo usermod -aG docker "${SUDO_USER:-$USER}"

# enable and start docker
sudo systemctl enable --now docker

# set selinux boolean to allow containers to manage cgroups, required on red had distributions
# the '|| true' ensures the script doesn't fail if setsebool cant be changed
sudo setsebool -P container_manage_cgroup 1 || true