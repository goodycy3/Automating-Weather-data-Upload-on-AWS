# Create a VPC
resource "aws_vpc" "weather_dashboard_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "WeatherDashboardVPC"
  }
}

# Create a public subnet
resource "aws_subnet" "weather_dashboard_public_subnet" {
  vpc_id                  = aws_vpc.weather_dashboard_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "WeatherDashboardPublicSubnet"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "weather_dashboard_igw" {
  vpc_id = aws_vpc.weather_dashboard_vpc.id
  tags = {
    Name = "WeatherDashboardIGW"
  }
}

# Create a Route Table for the public subnet
resource "aws_route_table" "weather_dashboard_public_route_table" {
  vpc_id = aws_vpc.weather_dashboard_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.weather_dashboard_igw.id
  }
  tags = {
    Name = "WeatherDashboardPublicRouteTable"
  }
}

# Associate the Route Table with the public subnet
resource "aws_route_table_association" "weather_dashboard_public_route_table_assoc" {
  subnet_id      = aws_subnet.weather_dashboard_public_subnet.id
  route_table_id = aws_route_table.weather_dashboard_public_route_table.id
}

# Create a Security Group to allow SSH access
resource "aws_security_group" "weather_dashboard_sg" {
  name        = "weather_dashboard_sg"
  description = "Allow SSH access"
  vpc_id      = aws_vpc.weather_dashboard_vpc.id

  ingress {
    description = "Allow SSH from My IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Replace with your public IP {Check here https://whatismyipaddress.com/} or you can set the default 0.0.0.0/0 from anywhere
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WeatherDashboardSG"
  }
}



# Generate a random ID for ensuring unique bucket naming
resource "random_id" "bucket_id" {
  keepers = {
    timestamp = timestamp() # Use timestamp for uniqueness
  }
  byte_length = 8 # Generate an 8-byte random ID
}

# Create an S3 bucket to store weather data
resource "aws_s3_bucket" "weather_data_bucket" {
  bucket = "weather-dashboard-data-${random_id.bucket_id.hex}" # Unique bucket name using a random ID
  tags = {
    Name        = "WeatherDashboardBucket" # Tag for identifying the bucket
    Environment = "Production"             # Specify the environment
  }
  force_destroy = true
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "versioning_weather_data_bucket" {
  bucket = aws_s3_bucket.weather_data_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}


# Create an IAM role to allow EC2 instance to access AWS resources
resource "aws_iam_role" "weather_dashboard_role" {
  name = "weather_dashboard_role" # Name of the IAM role

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


# Create a policy to allow access to the S3 bucket
resource "aws_iam_policy" "s3_access_policy" {
  name        = "weather_dashboard_s3_access"                      # Policy name
  description = "Allow access to the weather dashboard S3 bucket"  # Policy description

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject", 
        "s3:GetObject", 
        "s3:ListBucket",
        "s3:DeleteObject",
        "s3:DeleteObjectVersion",
        "s3:ListBucketVersions"
      ],
      "Resource": [
        "${aws_s3_bucket.weather_data_bucket.arn}",
        "${aws_s3_bucket.weather_data_bucket.arn}/*"
      ]
    }
  ]
}
EOF
}


# Attach the S3 access policy to the IAM role
resource "aws_iam_role_policy_attachment" "attach_s3_access" {
  role       = aws_iam_role.weather_dashboard_role.name # IAM role name
  policy_arn = aws_iam_policy.s3_access_policy.arn      # ARN of the S3 access policy
}

# Create an IAM Instance Profile to associate with the EC2 instance
resource "aws_iam_instance_profile" "weather_dashboard_instance_profile" {
  name = "weather_dashboard_instance_profile"     # Instance profile name
  role = aws_iam_role.weather_dashboard_role.name # Associated IAM role
}

# Generate an SSH key pair
resource "tls_private_key" "weather_dashboard_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Create an AWS Key Pair using the generated public key
resource "aws_key_pair" "weather_dashboard_keypair" {
  key_name   = "weather_dashboard_key"
  public_key = tls_private_key.weather_dashboard_key.public_key_openssh
}

# Save the private key locally as a .pem file
resource "local_file" "private_key_pem" {
  filename = "${path.module}/weather_dashboard_key.pem" # Path to save the key file
  content  = tls_private_key.weather_dashboard_key.private_key_pem
  file_permission = "0600" # Restrict permissions to owner only
}


# Create an EC2 instance to run the weather application
resource "aws_instance" "weather_dashboard_instance" {
  ami           = "ami-05576a079321f21f8" # (Amazon Linux 2023 AMI) Replace with a valid AMI ID for your region
  instance_type = "t2.micro"              # Instance type
  subnet_id     = aws_subnet.weather_dashboard_public_subnet.id # Associate with public subnet
  key_name      = aws_key_pair.weather_dashboard_keypair.key_name # Associate key pair

  iam_instance_profile = aws_iam_instance_profile.weather_dashboard_instance_profile.name # Attach IAM instance profile
  vpc_security_group_ids = [aws_security_group.weather_dashboard_sg.id] # Use security group ID

  # Use templatefile to include the Python script as part of user_data
  user_data = <<-EOF
#!/bin/bash
# Update and install required packages
sudo yum update -y
sudo yum install -y python3-pip
pip3 install boto3
pip3 install python-dotenv
sudo yum install cronie





# Create the Python script
cat <<EOT > /home/ec2-user/weather_to_s3.py
${templatefile("${path.module}/weather_to_s3.py", { bucket_name = aws_s3_bucket.weather_data_bucket.bucket })}
EOT

# Create the requirements.txt file
cat <<EOT > /home/ec2-user/requirements.txt
boto3==1.28.0
requests==2.31.0
python-dotenv==1.0.0
EOT

# Change ownership and permissions
chown ec2-user:ec2-user /home/ec2-user/weather_to_s3.py
chmod +x /home/ec2-user/weather_to_s3.py
chown ec2-user:ec2-user /home/ec2-user/requirements.txt
EOF

  tags = {
    Name = "WeatherDashboardInstance" # Tag for identifying the instance
  }
}






