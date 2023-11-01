data "aws_route53_zone" "target_host_zone" {
  name = "${var.domain_name}."
}

module "route53_records" {
  source = "terraform-aws-modules/route53/aws//modules/records"

  zone_id = data.aws_route53_zone.target_host_zone.zone_id

  records = [
    {
      name = "monit-${var.environment}"
      type = "CNAME"
      ttl  = 3600
      records = [
        module.alb.dns_name,
      ]
    },
    {
      name = "${var.api_path_prefix}"
      type = "CNAME"
      ttl  = 3600
      records = [
        module.alb.dns_name,
      ]
    },
  ]
}
