data "aws_iam_role" "deployer-role" {
    name = "deployer-${var.environment_name}"   
}