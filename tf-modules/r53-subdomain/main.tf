/**
 *## Route 53 Subdomain
 *
 * This module simplifies the code in creating a subdomain under an existing
 * domain.
 */
variable "name" {
    description = "name (FQDN) of the subdomain"
}
variable "parent_zone_id" {
    description = "Zone ID of the parent domain"
}
variable "ttl" {
    default = 172800
    description = "TTL for the NS records created"
}

resource "aws_route53_zone" "subdomain" {
    name = "${var.name}"
}

resource "aws_route53_record" "subdomain-NS" {
    zone_id = "${var.parent_zone_id}"
    name    = "${var.name}"
    type    = "NS"
    ttl     = "${var.ttl}"
    records = [
        "${aws_route53_zone.subdomain.name_servers.0}",
        "${aws_route53_zone.subdomain.name_servers.1}",
        "${aws_route53_zone.subdomain.name_servers.2}",
        "${aws_route53_zone.subdomain.name_servers.3}",
    ]
}
