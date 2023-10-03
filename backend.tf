terraform {
  backend "s3" {
    bucket = "example-devx-bucket"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}