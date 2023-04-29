terraform {
  required_version = "1.4.5" # default will be the latest version of terraform
  backend "s3" {
    region = "us-east-1"                              # region where bucket is
    bucket = "irina-tentech-backend-s3"               # name of the bucket
    key    = "batch8-lession-4-state-file-production" # name of the state file for this session
  }
}