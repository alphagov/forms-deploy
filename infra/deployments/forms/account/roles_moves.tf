
moved {
  from = aws_iam_role.codepipeline-readonly
  to   = aws_iam_role.codepipeline_readonly
}


moved {
  from = aws_iam_role_policy_attachment.codepipeline-readonly-policy
  to   = aws_iam_role_policy_attachment.codepipeline_readonly_policy
}
