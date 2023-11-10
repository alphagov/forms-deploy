# frozen_string_literal: true

require "aws-sdk-ecs"
require "aws-sdk-ssm"
require "colorize"
require_relative "../utilities/helpers"
require "net/http"
require "uri"

# Manages API Tokens for authenticating with forms-api service
class FormsApiTokens
  include Helpers

  def run
    @options = {}
    parse_options
    return unless valid_options?

    if @options.key?(:service)
      service
    else
      puts "Only the --service option is currently supported".red
    end
  end

private

  def service
    @environment = fetch_environment
    owner = @options[:service].to_s
    description = "Used by the #{@options[:service]} app"
    begin
      token = create_token(owner, description)
      update_ssm_parameter token
      redeploy_service
      puts 'Update complete. Use "forms ecs_summary" to monitor re-deployment'
    rescue RuntimeError => e
      puts "Something went wrong: #{e.message}".red
    end
  end

  def create_token(owner, description)
    forms_api_host = forms_app_host "api"
    uri = URI "https://#{forms_api_host}/api/v1/access-tokens"
    headers = { "Authorization" => "Token #{@options[:token]}" }

    form_params = "owner=#{owner}&description=#{description}"

    response = Net::HTTP.post(uri, form_params, headers)

    raise "Error response from forms-api: #{response.body}" unless response.code == "201"

    JSON.parse(response.body)["token"]
  end

  def update_ssm_parameter(token)
    ssm = Aws::SSM::Client.new
    opts = {
      name: "/#{@options[:service]}-#{@environment}/forms-api-key",
      value: token,
      type: "SecureString",
      overwrite: true,
    }
    ssm.put_parameter(opts)
  end

  def redeploy_service
    puts "redeploying #{@options[:service]} in #{@environment}"
    ecs = Aws::ECS::Client.new
    opts = {
      service: @options[:service],
      cluster: "forms-#{@environment}",
      force_new_deployment: true,
    }
    ecs.update_service(opts)
  end

  def valid_options?
    %i[token].each do |arg|
      if @options[arg].nil?
        puts "--#{arg} must be provided".red
        return false
      end
    end

    if @options.key?(:service)
      unless %w[forms-admin forms-runner].include? @options[:service]
        puts '--service must be "forms-admin" or "forms-runner"'.red
        return false
      end

      return aws_authenticated?
    end

    true
  end

  def parse_options
    OptionParser.new { |opts|
      opts.banner = "
      Manages api tokens for forms-api.

      May need to be run in a authorized shell using gds-cli or aws-vault, see
      individual options below.

      Example:
      gds aws forms-dev-support -- forms forms_api_tokens --service forms-admin --token a-valid-token\n\n"

      opts.on("-h", "--help", "Prints help") do
        puts opts
        exit
      end

      opts.on("-sSERVICE", "--service=SERVICE", 'Generates a new token for the
              service in the environment which the shell is authenticated for.
              Updates the necessary SSM Parameter and redeploys the service.
              Service must be forms-admin or forms-runner.
              Shell must be authorized for the required environment') do |service|
        @options[:service] = service
      end

      opts.on("-tTOKEN", "--token=TOKEN", "Valid forms-api token used to authenticate with forms-api") do |token|
        @options[:token] = token
      end
    }.parse!
  end
end
