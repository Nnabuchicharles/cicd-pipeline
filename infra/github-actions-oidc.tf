# GitHub OIDC Provider (one per AWS account)
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  # GitHub's OIDC root CA thumbprint (commonly used)
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# Role that GitHub Actions can assume (ONLY from your repo)
resource "aws_iam_role" "github_actions_deploy" {
  name = "${local.name}-github-actions-deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          },
          StringLike = {
            # ONLY allow this repo (any branch environment)
            "token.actions.githubusercontent.com:sub" = "repo:Nnabuchicharles/cicd-pipeline:*"
          }
        }
      }
    ]
  })
}

# Minimal permissions: push image to ECR + force ECS redeploy
resource "aws_iam_policy" "github_actions_deploy" {
  name = "${local.name}-github-actions-deploy-policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # ECR auth token (must be *)
      {
        Effect   = "Allow",
        Action   = ["ecr:GetAuthorizationToken"],
        Resource = "*"
      },
      # Push image to your specific repo
      {
        Effect = "Allow",
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ],
        Resource = aws_ecr_repository.this.arn
      },
      # Trigger new ECS deployment
      {
        Effect = "Allow",
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices"
        ],
        Resource = aws_ecs_service.this.id
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "github_actions_attach" {
  role       = aws_iam_role.github_actions_deploy.name
  policy_arn = aws_iam_policy.github_actions_deploy.arn
}

output "github_actions_role_arn" {
  value = aws_iam_role.github_actions_deploy.arn
}
