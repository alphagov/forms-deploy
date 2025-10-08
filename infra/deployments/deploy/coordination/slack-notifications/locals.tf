locals {
  chatbot_message_input_paths = {
    pipeline = "$.detail.pipeline"
    account  = "$.account"
    time     = "$.time"
  }
}
