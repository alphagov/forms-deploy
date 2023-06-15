# frozen_string_literal: true

require "optionparser"
require "aws-sdk-codepipeline"
require_relative "../utilities/printer"
require_relative "../utilities/helpers"

# Prints summary of CodePipelines in the deploy account
class PipelineSummary
  include Helpers

  def run
    @options = { filter: "" }
    parse_options

    return unless aws_authenticated?

    @codepipeline = Aws::CodePipeline::Client.new({})
    print_summaries
  end

private

  def print_summaries
    printer = Printer.new
    pipeline_summaries.each do |summary|
      printer.print_table(summary[:pipeline_name].to_s, summary[:actions])
    end
  end

  def parse_options
    OptionParser.new { |opts|
      opts.banner = "
      Returns the latest status for the deployment pipelines.

      Run in a authorized shell for forms-deploy using gds-cli or aws-vault.

      Example:
      gds aws gds-forms-deploy-support -- forms pipelines\n\n"

      opts.on("-h", "--help", "Prints help") do
        puts opts
        exit
      end
      opts.on("-fFILTER", "--filter=FILTER", "String to filter pipelines, defaults to empty") do |f|
        @options[:filter] = f
      end
    }.parse!
  end
end

def pipeline_summaries
  pipeline_names.map do |name|
    actions = @codepipeline
              .get_pipeline_state({ name: })
              .stage_states
              .map(&method(:pipeline_state_summary))
    { pipeline_name: name, actions: actions.flatten }
  end
end

def pipeline_state_summary(state)
  stage_name = state.stage_name
  state.action_states.map do |action|
    {
      stage_name:,
      action_name: action.action_name,
      status: action.latest_execution.nil? ? "unavailable" : action.latest_execution.status,
      time: action.latest_execution.nil? ? "unavailble" : action.latest_execution.last_status_change,
    }
  end
end

def pipeline_names
  @codepipeline
    .list_pipelines({})
    .pipelines
    .map(&:name)
    .filter { |name| name.include?(@options[:filter]) }
end

PipelineSummary.new.run if __FILE__ == $PROGRAM_NAME
