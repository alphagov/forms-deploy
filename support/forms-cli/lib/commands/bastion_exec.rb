# frozen_string_literal: true

require_relative "../utilities/bastion"
require_relative "../utilities/helpers"

class BastionExec
  def run
    @environment = fetch_environment
    @bastion = Bastion.new(@environment)

    options = parse_options

    @bastion.run(**options)
  end

private

  include Helpers

  def parse_options
    options = {}

    OptionParser.new do |opts|
      opts.on("--setup") do
        @bastion.setup
        puts "Applied bastion configuration to #{@environment}"
        exit
      end

      opts.on("--teardown") do
        @bastion.teardown
        puts "Deleted bastion configuration from #{@environment}"
        exit
      end

      opts.on("-cCOMMAND", "--command=command", "The command to run on the bastion container")
    end.parse!(into: options)

    options
  end
end
