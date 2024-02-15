variable "environment_name" {
  type        = string
  description = "The name of the enviroment the logging is being deployed to  "
}

variable "log_group_subject" {
  type        = string
  description = "The subject of the log group. For example 'git-commits'. This will act as a suffix to the log group name"
}

variable "event_pattern" {
  type        = string
  description = "A JSON encoded event pattern for matching the events to be logged"
}