# frozen_string_literal: true

require "colorize"
require "aws-sdk-sts"

# Helper methods for common operations
module Helpers
  ACCOUNT_IDS = {
    "498160065950" => "dev",
    "972536609845" => "staging",
    "443944947292" => "production",
    "619109835131" => "user-research",
  }.freeze

  FORMS_API_DOMAINS = {
    "dev" => "api.dev.forms.service.gov.uk",
    "staging" => "api.staging.forms.service.gov.uk",
    "production" => "api.forms.service.gov.uk",
    "user-research" => "api.research.forms.service.gov.uk",
  }.freeze

  def aws_authenticated?
    return true if expected_aws_environment_variable

    puts "You must be authenticated to run this command. Use --help"\
      " for further instructions".red
    false
  end

  def fetch_environment
    if ENV["FORMS_ENV"].nil? || ENV["FORMS_ENV"].empty?
      sts = Aws::STS::Client.new
      account = sts.get_caller_identity({}).account
      ACCOUNT_IDS[account]
    else
      ENV["FORMS_ENV"]
    end
  end

private

  def expected_aws_environment_variable
    !ENV["AWS_ACCESS_KEY_ID"].nil? &&
      !ENV["AWS_REGION"].nil? &&
      !ENV["AWS_SECRET_ACCESS_KEY"].nil? &&
      !ENV["AWS_SESSION_TOKEN"].nil?
  end
end
