# frozen_string_literal: true

require 'optparse'
require_relative 'commands/ecs_summary'
require_relative 'commands/get_parameters'
require_relative 'commands/pipeline_summary'
require_relative 'commands/notify'
require_relative 'commands/data_api'
require_relative 'commands/forms_api_tokens'
require 'colorize'

# Add new commands here
COMMANDS = {
  ecs_summary: -> { EcsSummary.new.run },
  get_parameters: -> { GetParameters.new.run },
  pipeline_summary: -> { PipelineSummary.new.run },
  notify: -> { Notify.new.run },
  data_api: -> { DataApi.new.run },
  forms_api_tokens: -> { FormsApiTokens.new.run }
}.freeze

command = ARGV[0]

if !command.nil? && COMMANDS.key?(command.to_sym)
  COMMANDS[command.to_sym].call
else
  puts 'Available commands:'.blue
  COMMANDS.each_key { |name| puts name.to_s }
  puts "\n\nFor individual command usage: '<command> --help'"
end
