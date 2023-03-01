# frozen_string_literal: true

require 'colorize'

# Helper methods for common operations
module Helpers
  def aws_authenticated?
    return true if expected_aws_environment_variable

    puts 'You must be authenticated to run this command. Use --help'\
      ' for further instructions'.red
    false
  end

  private

  def expected_aws_environment_variable
    !ENV['AWS_ACCESS_KEY_ID'].nil? &&
      !ENV['AWS_REGION'].nil? &&
      !ENV['AWS_SECRET_ACCESS_KEY'].nil? &&
      !ENV['AWS_SESSION_TOKEN'].nil?
  end
end
