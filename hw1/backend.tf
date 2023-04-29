terraform {
    required_version = "1.4.5"
    backend "s3" {
        region = "us-east-1"
        bucket = "my-terraform-hw1-bucket-irina"
        key = "hw1-state-file-tentech"
    }
}