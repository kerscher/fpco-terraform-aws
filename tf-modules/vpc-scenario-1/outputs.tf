//VPC id
output "vpc_id" {
  value = "${aws_vpc.main.id}"
}

//List of public subnet ids
output "public_subnet_ids" {
  value = ["${aws_subnets.public.ids}"]
}

// Route table id associated with public subnets
output "public_route_table_id" {
  value = "${aws_route_table.public.id}"
}

//Internet gateway id
output "igw_id" {
  value = "${aws_internet_gateway.main.id}"
}
