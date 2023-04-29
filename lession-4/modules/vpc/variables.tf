variable "cidr_block" {
    description = "this is a variable for cidr block for vpc"
    type = string 
    default = "10.0.0.0/24"
}

variable "vpc_tag" {
    type = string
    
}