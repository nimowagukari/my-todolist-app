data "aws_ami" "this" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-ecs-hvm-*-kernel-6.1-x86_64"]
  }
}

resource "aws_ecr_repository" "this" {
  name         = "todolist/backend/express-prisma"
  force_delete = true
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
resource "aws_iam_role" "this" {
  name = "ecsTaskExecutionRole@todolist-backend-express-prisma"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}
data "aws_iam_policy_document" "ssm-getparams" {
  # 参考：https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_execution_IAM_role.html#task-execution-private-auth
  statement {
    actions = [
      "ssm:GetParameters"
    ]
    resources = ["arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/my-todolist-app/*"]
  }
}
resource "aws_iam_role_policy" "ssm-getparams" {
  name   = "ssm-getparams"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.ssm-getparams.json
}
data "aws_iam_policy_document" "ecr" {
  # 参考：https://docs.aws.amazon.com/ja_jp/AmazonECR/latest/userguide/security_iam_id-based-policy-examples.html#security_iam_id-based-policy-examples-access-one-bucket
  statement {
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
    ]
    resources = [
      "arn:aws:ecr:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:repository/todolist/backend/express-prisma"
    ]
  }
}
resource "aws_iam_role_policy" "ecr" {
  name   = "ecr"
  role   = aws_iam_role.this.id
  policy = data.aws_iam_policy_document.ecr.json
}
