#!/bin/bash
# For Ubuntu 22.04
# Intsalling Java
sudo apt update -y
sudo apt install openjdk-17-jre -y
sudo apt install openjdk-17-jdk -y
sudo java --version

# Installing Jenkins
sudo curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
sudo echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update -y
sudo apt-get install jenkins -y

# Enabling jenkins service
sudo service jenkins start
sudo systemctl enable jenkins


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

sudo apt-get install wget apt-transport-https gnupg -y
wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor | sudo tee /usr/share/keyrings/trivy.gpg > /dev/null
echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" | sudo tee -a /etc/apt/sources.list.d/trivy.list
sudo apt-get update
sudo apt-get install trivy

# Assign Terraform templatefile variables to shell variables
DOCKER_USERNAME="${docker_username}"
DOCKER_PASSWORD="${docker_password}"

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