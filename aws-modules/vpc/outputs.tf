output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_arn" {
  value = aws_vpc.main.arn
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "vpc_dns_hostnames" {
  value = aws_vpc.main.enable_dns_hostnames
}

output "vpc_dns_support" {
  value = aws_vpc.main.enable_dns_support
}
