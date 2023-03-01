# frozen_string_literal: true

require 'optionparser'
require 'aws-sdk-ecs'
require 'aws-sdk-sts'
require_relative '../utilities/printer'
require_relative '../utilities/helpers'

# Prints the ECS summary details of an environment
class EcsSummary
  include Helpers

  ACCOUNT_IDS = {
    '498160065950' => 'dev',
    '972536609845' => 'staging',
    '443944947292' => 'production',
    '619109835131' => 'user-research'
  }.freeze

  def run
    parse_options

    return unless aws_authenticated?

    @environment = fetch_environment
    @ecs = Aws::ECS::Client.new

    Printer.new.print_table("ECS summary for #{@environment}", summaries)
  end

  private

  def parse_options
    OptionParser.new do |opts|
      opts.banner = "
         Prints ECS summary details for the environment currently
         authenticated. Must be run in an authorized shell using the gds-cli or
         aws-vault.

         Example:
         gds aws gds-forms-dev-readonly -- forms ecs_summary\n\n"

      opts.on('-h', '--help', 'Prints help') do
        puts opts
        exit
      end
    end.parse!
  end

  def fetch_environment
    sts = Aws::STS::Client.new
    account = sts.get_caller_identity({}).account
    ACCOUNT_IDS[account]
  end

  # rubocop:disable Metrics/AbcSize
  def summaries
    fetch_services.map do |service|
      {
        name: service.service_name,
        state: service.deployments[0].rollout_state,
        desired: service.deployments[0].desired_count,
        running: service.deployments[0].running_count,
        pending: service.deployments[0].pending_count,
        failed: service.deployments[0].failed_tasks,
        image: fetch_task_image(service.deployments[0].task_definition),
        latest_event: service.events[0].message
      }
    end
  end
  # rubocop:enable Metrics/AbcSize

  def fetch_services
    opts = {
      cluster: "forms-#{@environment}",
      services: %w[forms-api forms-admin forms-runner]
    }
    @ecs.describe_services(opts).services
  end

  def fetch_task_image(task_definition)
    opts = { task_definition: }
    @ecs.describe_task_definition(opts)
        .task_definition.container_definitions[0]
        .image
        .split('/')[1]
  end
end

EcsSummary.new.run if __FILE__ == $PROGRAM_NAME
