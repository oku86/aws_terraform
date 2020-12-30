# -----------------------------------------------------------------------------
# CREATE DNS ZONE
# -----------------------------------------------------------------------------

resource "aws_route53_zone" "check_co" {
  name = "check.co"

  tags = {
    Name              = "check.co"
    ops_terraformed   = var.ops_terraformed
    ops_environment   = data.template_file.environment.rendered
  }
}

# -----------------------------------------------------------------------------
# CREATE SSL CERTIFICATE & VALIDATION DNS RECORD
# -----------------------------------------------------------------------------

resource "aws_acm_certificate" "check_ssl_cert" {
  domain_name       = "*.check.co"
  validation_method = "DNS"

  tags = {
    Name              = "check.co"
    ops_terraformed   = var.ops_terraformed
    ops_environment   = data.template_file.environment.rendered
  }

  lifecycle {
    create_before_destroy = true
  }
}

# SSL Cert validation will fail because I don't own this domain (just for demonstration purposes)
resource "aws_route53_record" "cert_validation_check_co" {
  for_each = {
    for dvo in aws_acm_certificate.check_ssl_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  type            = each.value.type
  zone_id         = aws_route53_zone.check_co.zone_id
  ttl             = 86400
}

# -----------------------------------------------------------------------------
# CREATE THE SECURITY GROUP THAT CONTROLS WHAT TRAFFIC CAN GO IN AND OUT OF THE ALB
# -----------------------------------------------------------------------------

resource "aws_security_group" "alb_access" {
  name        = "${data.template_file.environment.rendered}-shared-alb"
  description = "Security group for ${data.template_file.environment.rendered} shared ALB"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  tags = {
    Name              = "${data.template_file.environment.rendered}-shared-alb"
    ops_terraformed   = var.ops_terraformed
    ops_environment   = data.template_file.environment.rendered
  }
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.alb_access.id
}

# HTTP listener for testing purposes (using a temporary test DNS domain)
resource "aws_security_group_rule" "allow_inbound_http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
  description = "External 0.0.0.0/0 access to Shared ALB"

  security_group_id = aws_security_group.alb_access.id
}

# To be used for PRODUCTION
resource "aws_security_group_rule" "allow_inbound_https" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "TCP"
  cidr_blocks = ["0.0.0.0/0"]
  description = "External 0.0.0.0/0 access to Shared ALB"

  security_group_id = aws_security_group.alb_access.id
}

# -----------------------------------------------------------------------------
# CREATE S3 BUCKET FOR ALB LOGS
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "alb_logs" {
  bucket = "${data.template_file.environment.rendered}-shared-alb-logs"
  acl    = "private"

  tags = {
    Name              = "${data.template_file.environment.rendered}-shared-alb-logs"
    ops_terraformed   = var.ops_terraformed
    ops_environment   = data.template_file.environment.rendered
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -----------------------------------------------------------------------------
# ALB
# -----------------------------------------------------------------------------

resource "aws_lb" "alb" {
  name                       = "${data.template_file.environment.rendered}-shared-alb"
  internal                   = var.internal
  subnets                    = tolist(data.terraform_remote_state.network.outputs.public_subnets)
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb_access.id]
  enable_deletion_protection = true

  /*
  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    prefix  = "shared"
    enabled = true
  }
  */

  tags = {
    Name              = "${data.template_file.environment.rendered}-shared-alb"
    ops_terraformed   = var.ops_terraformed
    ops_environment   = data.template_file.environment.rendered
  }
}

# -----------------------------------------------------------------------------
# TARGET GROUPS AND LISTENER
# -----------------------------------------------------------------------------

# Just for testing (for PROD use HTTPS listener & target group defined below)
resource "aws_lb_target_group" "target_group_default_shared_http" {
  name     = "${data.template_file.environment.rendered}-cluster-01-shared"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id
}

resource "aws_lb_listener" "alb_listener_shared_http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_lb_target_group.target_group_default_shared_http.arn
    type             = "forward"
  }
}

# TO be used for PROD (ALB listener requires a valid SSL cert)
/*
resource "aws_lb_target_group" "target_group_default_shared_https" {
  name     = "${data.template_file.environment.rendered}-cluster-01-shared"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id
}

resource "aws_lb_listener" "alb_listener_shared_https" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = var.ssl_policy
  certificate_arn   = aws_acm_certificate.check_ssl_cert.arn

  default_action {
    target_group_arn = aws_lb_target_group.target_group_default_shared.arn
    type             = "forward"
  }
}
*/
