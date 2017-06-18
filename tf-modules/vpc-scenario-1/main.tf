/**
 *## AWS VPC, Scenario 1: VPC w/ Public Subnets
 *
 * This module creates a VPC with public subnets across one or more availability
 * zones, an internet gateway, and a route table for those subnets to pass
 * traffic through the gateway.
 *
 * Scenario 1 from AWS docs:
 * http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Scenarios.html
 *
 */
resource "aws_vpc" "main" {
  cidr_block           = "${var.cidr}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"
  tags = "${merge(map("Name", "${var.name_prefix}"), "${var.extra_tags}")}"
}

// move these two into their own module?
resource "aws_vpc_dhcp_options" "main" {
  domain_name         = "${var.region}.compute.internal"
  domain_name_servers = "${var.dns_servers}"

  tags = "${merge(map("Name", "${var.name_prefix}"), "${var.extra_tags}")}"
}

resource "aws_vpc_dhcp_options_association" "main" {
  vpc_id          = "${aws_vpc.main.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.main.id}"
}

module "public-subnets" {
  source      = "../subnets"
  azs         = "${var.azs}"
  vpc_id      = "${aws_vpc.main.id}"
  name_prefix = "${var.name_prefix}-public"
  cidr_blocks = "${var.public_subnet_cidrs}"
  extra_tags  = "${var.extra_tags}"
}

// Internet Gateway - provide internet access to public subnets.
resource "aws_internet_gateway" "main" {
  vpc_id = "${aws_vpc.main.id}"

  tags = "${merge(map("Name", "${var.name_prefix}"), "${var.extra_tags}")}"
}

// route table and link to subnets
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.main.id}"
  }

  tags = "${merge(map("Name", "${var.name_prefix}-public"), "${var.extra_tags}")}"
}

resource "aws_route_table_association" "public-rta" {
  count          = "${length(var.public_subnet_cidrs)}"
  subnet_id      = "${element(module.public-subnets.ids, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}
