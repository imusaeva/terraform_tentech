provider "aws" {
  region = "us-east-1"
  # access_key = var.access_key - var for access key and secret key that we set up 
  # secret_key = var.secret_key
  profile = "default" # if you configure 2 accounts in aws cli by : aws config --profile and choose here default or new credentials to use
}

