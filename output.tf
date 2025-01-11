# Output the S3 bucket name
output "bucket_name" {
  value = aws_s3_bucket.weather_data_bucket.bucket # Output the bucket name
}

# Output the ARN of the IAM role
output "role_arn" {
  value = aws_iam_role.weather_dashboard_role.arn # Output the role ARN
}

# Output the EC2 instance ID
output "ec2_instance_id" {
  value = aws_instance.weather_dashboard_instance.id # Output the instance ID
}


# Outputs for reference
output "key_pair_name" {
  value = aws_key_pair.weather_dashboard_keypair.key_name
}

output "public_ip" {
  value = aws_instance.weather_dashboard_instance.public_ip
}
