# -----------------------------------------------------------------------------
# CREATE ECR REPOSITORY
# -----------------------------------------------------------------------------

resource "aws_ecr_repository" "ecr" {
  name = "check_co"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name            = "check_co"
    ops_terraformed = var.ops_terraformed
    ops_environment = data.template_file.environment.rendered
  }
}