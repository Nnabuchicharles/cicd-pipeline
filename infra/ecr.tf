resource "aws_ecr_repository" "this" {
  name = "${local.name}-repo"
  image_scanning_configuration {
    scan_on_push = true
  }
}
