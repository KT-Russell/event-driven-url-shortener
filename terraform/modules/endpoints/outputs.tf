output "interface_endpoint_ids" {
  description = "IDs of interface VPC endpoints keyed by AWS service"
  value = {
    for service, endpoint in aws_vpc_endpoint.interface :
    service => endpoint.id
  }
}

output "s3_gateway_endpoint_id" {
  description = "ID of the S3 gateway VPC endpoint"
  value       = aws_vpc_endpoint.s3.id
}