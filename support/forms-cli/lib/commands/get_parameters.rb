# frozen_string_literal: true

require "optionparser"
require "aws-sdk-ssm"
require "colorize"
require_relative "../utilities/printer"
require_relative "../utilities/helpers"

# Prints ssm parameters from the authenticated environment
class GetParameters
  include Helpers

  def run
    @options = {
      decrypt: false,
      path: "/",
    }
    parse_command_options

    return unless aws_authenticated? && valid_options?

    @ssm = Aws::SSM::Client.new

    Printer.new.print_table("Parameters", fetch_parameters)
  end

private

  def valid_options?
    unless @options[:path].start_with?("/")
      puts '-p, --path must begin with "/"'.red
      return false
    end
    true
  end

  def fetch_parameters
    get_parameters_by_path.map do |param|
      {
        name: param.name,
        value: @options[:decrypt] ? param.value : "********",
      }
    end
  end

  def get_parameters_by_path(next_token: nil)
    opts = {
      path: @options[:path],
      recursive: true,
      with_decryption: @options[:decrypt],
      next_token:,
    }

    results = @ssm.get_parameters_by_path(opts)

    return results.parameters if results.next_token.nil?

    results.parameters.concat(get_parameters_by_path(next_token: results.next_token))
  end

  def parse_command_options
    OptionParser.new { |opts|
      opts.banner = "
      Returns SSM Parameters using aws ssm get-parameters-by-path.

      Run in a authorized shell using gds-cli or aws-vault

      Example:
      gds aws forms-dev-support -- forms get_parameters\n\n"

      opts.on("-h", "--help", "Prints help") do
        puts opts
        exit
      end
      opts.on("-pPATH", "--path=PATH", "Path to filter on, must begin with /, defaults to /") do |p|
        @options[:path] = p
      end
      opts.on("-d", "--decrypt", "Decrypt and show values, defaults to false") do |d|
        @options[:decrypt] = d
      end
    }.parse!
  end
end

GetParameters.new.run if __FILE__ == $PROGRAM_NAME
