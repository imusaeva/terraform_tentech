data "aws_availability_zones" "az" {
    state = "available"
}

resource "aws_subnet" "subnet" {
    count = length(var.subnet_cidr_blocks)
    availability_zone = count.index % 2 == 0 ? data.aws_availability_zones.az.names[0] : data.aws_availability_zones.az.names[1]
    cidr_block = var.subnet_cidr_blocks[count.index]
    map_public_ip_on_launch = var.map_public_ip_on_launch
    vpc_id = var.vpc_id

    tags = {
        Name = "${var.map_public_ip_on_launch == true ? "public" : "private"}_${data.aws_availability_zones.az.names[count.index]}"
    }
}