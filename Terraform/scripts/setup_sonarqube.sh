#!/bin/bash

# Update the package index
sudo apt-get update

# Install prerequisite packages for Docker
sudo apt-get install ca-certificates curl

# Create a directory for Docker's GPG key and download it
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the Docker repository to the Apt sources list
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the package index again to include Docker's repository
sudo apt-get update

# Install Docker and its associated plugins
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Add the 'ubuntu' user to the 'docker' group to enable running Docker without sudo
sudo usermod -aG docker ubuntu

# Adjust permissions for the Docker socket to avoid permission issues
sudo chmod 777 /var/run/docker.sock

# Restart Docker demon
sudo systemctl restart docker

# Pull and run the SonarQube container, exposing it on port 9000
docker run -d --name sonarqube -p 9000:9000 sonarqube:lts-community