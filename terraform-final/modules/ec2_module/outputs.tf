output "proxy-id" {
  value = aws_instance.proxy-servers[*].id
}

output "apache-id" {
  value = aws_instance.apache_servers[*].id
}