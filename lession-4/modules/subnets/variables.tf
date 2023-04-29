variable "subnet_cidr_blocks" {
    type = list(string)
}
variable "map_public_ip_on_launch" {
    type = bool
}
variable "vpc_id" {
    type = string
}