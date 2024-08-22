resource "aws_dynamodb_table" "state_locking_table" {
  #checkov:skip=CKV_AWS_28:we don't need point in time recovery on this table
  #checkov:skip=CKV_AWS_119:we don't require encryption on this table
  name         = "govuk-forms-deploy-tfstate-locking"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}