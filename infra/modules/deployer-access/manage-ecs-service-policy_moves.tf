
moved {
  from = aws_iam_policy.ecs-service
  to   = aws_iam_policy.ecs_service
}


moved {
  from = aws_iam_role_policy_attachment.ecs-service
  to   = aws_iam_role_policy_attachment.ecs_service
}
