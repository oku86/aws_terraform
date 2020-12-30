# -----------------------------------------------------------------------------
# ROUTE53 ENTRY
# -----------------------------------------------------------------------------

resource "aws_route53_record" "check_co_dns" {
  zone_id = data.terraform_remote_state.alb.outputs.check_co_zone_id
  name    = "www.check.co"
  type    = "CNAME"
  ttl     = 86400
  records = [data.terraform_remote_state.alb.outputs.load_balancer_dns_name]
}

