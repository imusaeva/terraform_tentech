# create s3 bucket:
resource "aws_s3_bucket" "my_s3_bucket" {
  bucket = "my-tf-test-bucket-tentech-irina"
}

# create s3 bucket:
resource "aws_s3_bucket" "my_s3_bucket2" {
  bucket = "my-tf-test-bucket-tentech-irina-2"
}

# create vpc:
resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16" 

  tags = {
    Name = "first-lesson-vpc-upgraded"
  }
}