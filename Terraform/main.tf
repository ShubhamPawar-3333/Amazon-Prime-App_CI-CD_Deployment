provider "aws" {
  region = "ap-south-1"
}

# Generate the private key
resource "tls_private_key" "project_setup_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create the AWS Key Pair using the generated public key
resource "aws_key_pair" "project_setup_key" {
  key_name   = var.key_name
  public_key = tls_private_key.project_setup_key.public_key_openssh
}

# Save the private key to a local file with proper permissions
resource "local_file" "setup_pem" {
  content         = tls_private_key.project_setup_key.private_key_pem
  filename        = "${path.root}/../${aws_key_pair.project_setup_key.key_name}.pem"
  file_permission = "0600" # Set permissions for the private key to be secure
}

resource "aws_security_group" "prime_app_sg" {
  name        = "prime-app-sg"
  description = "Allow necessary inbound traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH access"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP access"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS access"
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Jenkins access"
  }

  ingress {
    from_port   = 9000
    to_port     = 9000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SonarQube access"
  }

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Node Exporter access"

  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Grafana & App Port access"
  }

  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow Prometheus access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "PrimeAppSecurityGroup"
  }
}

resource "aws_instance" "jenkins_instance" {
  ami           = var.ami_id
  instance_type = var.instance_types["jenkins"]

  key_name        = aws_key_pair.project_setup_key.key_name
  security_groups = [aws_security_group.prime_app_sg.name]

  user_data = templatefile("./scripts/setup_jenkins.sh", {})

  root_block_device {
    volume_size = 25    # Set the size to 25GB
    volume_type = "gp2" # General Purpose SSD
  }

  tags = {
    Name = "Jenkins-Server"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${path.root}/../${aws_key_pair.project_setup_key.key_name}.pem"
    host        = self.public_ip
  }
}

resource "aws_instance" "tools_instance" {
  ami           = var.ami_id
  instance_type = var.instance_types["tools"]

  key_name        = aws_key_pair.project_setup_key.key_name
  security_groups = [aws_security_group.prime_app_sg.name]

  # Define the block device (25GB size)
  root_block_device {
    volume_size = 25    # Set the size to 25GB
    volume_type = "gp2" # General Purpose SSD
  }

  user_data = templatefile("./scripts/setup_tools.sh", {
    docker_username = var.docker_username
    docker_password = var.docker_password
  })

  tags = {
    Name = "tools-server"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = "${path.root}/../${aws_key_pair.project_setup_key.key_name}.pem"
    host        = self.public_ip
  }
}



