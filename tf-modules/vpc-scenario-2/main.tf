/**
 *## AWS VPC, Scenario 2: VPC w/ both Public & Private Subnets, NAT and Internet Gateway
 *
 * This module creates a VPC with both public and private subnets across one or
 * more availability zones. The public subnets have routes to the public
 * thru an Internet Gateway, while the private subnets use NAT Gateways.
 *
 * Scenario 2 from AWS docs:
 * http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Scenarios.html
 *
 */

module "vpc" {
  source               = "../vpc"
  region               = "${var.region}"
  cidr                 = "${var.cidr}"
  name_prefix          = "${var.name_prefix}"
  enable_dns_hostnames = "${var.enable_dns_hostnames}"
  enable_dns_support   = "${var.enable_dns_support}"
  dns_servers          = ["${var.dns_servers}"]
  extra_tags           = "${var.extra_tags}"
}

module "public-subnets" {
  source      = "../subnets"
  azs         = "${var.azs}"
  vpc_id      = "${module.vpc.id}"
  name_prefix = "${var.name_prefix}-public"
  cidr_blocks = "${var.public_subnet_cidrs}"
  extra_tags  = "${var.extra_tags}"
}

module "public-gateway" {
  source      = "../route-public"
  vpc_id      = "${module.vpc.id}"
  name_prefix = "${var.name_prefix}-public"
  extra_tags  = "${var.extra_tags}"
  public_subnet_ids = ["${module.public-subnets.ids}"]
}

module "private-subnets" {
  source      = "../subnets"
  azs         = "${var.azs}"
  vpc_id      = "${module.vpc.id}"
  name_prefix = "${var.name_prefix}-private"
  cidr_blocks = "${var.private_subnet_cidrs}"
  extra_tags  = "${var.extra_tags}"
}

module "nat-gateway" {
  source             = "../nat-gateways"
  vpc_id             = "${module.vpc.id}"
  name_prefix        = "${var.name_prefix}"
  nat_count          = "${length(module.private-subnets.ids)}"
  public_subnet_ids  = ["${module.public-subnets.ids}"]
  private_subnet_ids = ["${module.private-subnets.ids}"]
  extra_tags         = "${var.extra_tags}"
}
