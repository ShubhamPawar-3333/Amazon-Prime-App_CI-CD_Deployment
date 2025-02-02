#!/bin/bash

# Assign Terraform templatefile variables to shell variables
DOCKER_USERNAME="${1}"
DOCKER_PASSWORD="${2}"

# Check if username and password are provided
if [ -z "$DOCKER_USERNAME" ] || [ -z "$DOCKER_PASSWORD" ]; then
    echo "Error: DOCKER_USERNAME and DOCKER_PASSWORD environment variables are required."
    exit 1
fi

# Perform Docker login
echo "Logging into Docker Hub..."
echo "$DOCKER_PASSWORD" | docker login --username "$DOCKER_USERNAME" --password-stdin

if [ $? -eq 0 ]; then
    echo "Docker login successful!"
else
    echo "Docker login failed. Please check credentials."
    exit 1
fi

# Install Docker Scout
echo "Installing Docker Scout..."
sudo curl -sSfL https://raw.githubusercontent.com/docker/scout-cli/main/install.sh | sudo sh -s -- -b /usr/local/bin

# Adjust permissions for the Docker socket to avoid permission issues
sudo chmod 777 /var/run/docker.sock
