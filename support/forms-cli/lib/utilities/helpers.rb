# frozen_string_literal: true

require 'colorize'
require 'aws-sdk-sts'

# Helper methods for common operations
module Helpers
  ACCOUNT_IDS = {
    '498160065950' => 'dev',
    '972536609845' => 'staging',
    '443944947292' => 'production',
    '619109835131' => 'user-research'
  }.freeze

  def aws_authenticated?
    return true if expected_aws_environment_variable

    puts 'You must be authenticated to run this command. Use --help'\
      ' for further instructions'.red
    false
  end

  def fetch_environment
    sts = Aws::STS::Client.new
    account = sts.get_caller_identity({}).account
    ACCOUNT_IDS[account]
  end

  private

  def expected_aws_environment_variable
    !ENV['AWS_ACCESS_KEY_ID'].nil? &&
      !ENV['AWS_REGION'].nil? &&
      !ENV['AWS_SECRET_ACCESS_KEY'].nil? &&
      !ENV['AWS_SESSION_TOKEN'].nil?
  end
end
