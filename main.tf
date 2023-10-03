resource "aws_security_group" "tf_sg" {
  name        = "Terraform-sg"
  description = "Security group for EC2 instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "terraform_instance" {
  ami                    = "ami-0bb4c991fa89d4b9b"
  instance_type          = "t2.micro"
  key_name               = "A4L"
  vpc_security_group_ids = [aws_security_group.tf_sg.id]
  availability_zone      = "us-east-1a"
  iam_instance_profile   = aws_iam_instance_profile.example_instance_profile.name
  tags = {
    Name = "terraform"
  }
}

resource "aws_s3_bucket" "example_bucket" {
  bucket = "example-devx-bucket"
  acl    = "private"

  tags = {
    Name = "giridevx-bucket"
  }
}

resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2_s3_role"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [{
      Effect : "Allow",
      Principal : {
        Service : "ec2.amazonaws.com"
      },
      Action : "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_read_only_policy" {
  name = "s3_read_only_policy"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [{
      Effect : "Allow",
      Action : [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      Resource : "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_read_only_policy" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = aws_iam_policy.s3_read_only_policy.arn
}

resource "aws_iam_instance_profile" "example_instance_profile" {
  name = "example-ec2-instance-profile"
  role = aws_iam_role.ec2_s3_role.id
}

resource "aws_ebs_volume" "example_ebs_volume" {
  availability_zone = "us-east-1a"
  size              = 7
}

resource "aws_volume_attachment" "example_ebs_attachment" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.example_ebs_volume.id
  instance_id = aws_instance.terraform_instance.id
}