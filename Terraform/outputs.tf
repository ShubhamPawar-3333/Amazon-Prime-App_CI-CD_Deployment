# Output Jenkins Public IP
output "jenkins_public_ip" {
  value       = aws_instance.jenkins_instance.public_ip
  description = "Public IP of the Jenkins instance"
}

# Output SSH Command
output "jenkins_server_ssh_command" {
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.jenkins_instance.public_ip}"
  description = "SSH command to connect to the Jenkins server"
}

# Output Tools Instance Public IP
output "tools_public_ip" {
  value       = aws_instance.tools_instance.public_ip
  description = "Public IP of the Jenkins instance"
}

# Output SSH Command
output "tools_server_ssh_command" {
  value       = "ssh -i ${var.key_name}.pem ubuntu@${aws_instance.tools_instance.public_ip}"
  description = "SSH command to connect to the Jenkins server"
}