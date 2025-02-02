variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_types" {
  description = "Instance types for Jenkins and other tools"
  type        = map(string)
}

variable "docker_username" {
  description = "Docker username"
  type        = string
}

variable "docker_password" {
  description = "Docker password"
  type        = string
  sensitive   = true
}

