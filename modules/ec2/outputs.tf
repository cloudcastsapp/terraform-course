output "app_eip" {
  value = aws_eip.cloudcasts_addr.*.public_ip
}

output "app_instance" {
  value = aws_instance.cloudcasts_web.id
}