# frozen_string_literal: true

require "optionparser"

require "aws-sdk-ec2"
require "aws-sdk-ecs"

require_relative "../utilities/cloudwatch_follow"
require_relative "../utilities/helpers"

class RunTask
  def run
    options = parse_options

    env = fetch_environment
    app = options[:app]
    command = ["rails", options[:command]]

    if options[:dry_run]
      puts "Would run `#{command.join(' ')}` using app forms-#{app} in #{env}"
      exit
    end

    puts "Running task `#{command.join(' ')}` using app forms-#{app}"

    self.task_runner = TaskRunner.new(
      env,
      app,
      command,
    )

    task = task_runner.run_task
    task_arn = task.task_arn
    start_time = Time.now

    puts "Waiting for task #{task_arn} to start..."
    sleep(1) until task_running?

    log_follower = CloudWatchFollow.new(env, app, task_arn:)
      .follow_log_events(start_time)

    loop do
      events = log_follower.next

      if events.empty?
        if task_stopped?
          puts "Quitting..."
          break
        else
          sleep(0.5)
          next
        end
      end

      events.each do |event|
        puts event.message
      end
    end
  end

private

  include Helpers

  attr_accessor :task_runner

  def task_running?
    task = task_runner.describe_task

    case task.last_status
    when "STOPPING", "STOPPED"
      if task.stop_code == "EssentialContainerExited"
        true
      else
        raise "Failed to start container: #{task.stop_code} #{task.stopped_reason}"
      end
    when "RUNNING"
      puts "Task #{task.last_status}"
      true
    else
      false
    end
  end

  def task_stopped?
    task = task_runner.describe_task

    case task.last_status
    when "STOPPED"
      puts "Task #{task.last_status}: #{task.stopped_reason}"
      true
    else
      false
    end
  end

  def parse_options
    options = {}

    OptionParser.new { |opts|
      opts.banner = "
        Run a Rails task in ECS using the specified app.

        Example:
        gds aws forms-dev-support -- forms run_task --app admin --command organisations:fetch\n\n"

      opts.on("-h", "--help", "Prints help") do
        puts opts
        exit
      end

      opts.on("-aAPP", "--app=APP", %w[admin api], "app to run command with")

      opts.on("-cCOMMAND", "--command=command", "Rails command to run, must be defined in app")

      opts.on("-n", "--dry_run", "Don't actually run task, just show what would be done")
    }.parse!(into: options)

    required_options = %i[app command]
    missing_options = required_options - options.keys

    unless missing_options.empty?
      abort "Missing required options: #{missing_options}"
    end

    options
  end

  class TaskRunner
    def initialize(env, app, command)
      @env = env
      @app = app
      @command = command
      @last_status = nil
      @task_arn = nil

      @ec2 = Aws::EC2::Client.new
      @ecs = Aws::ECS::Client.new
    end

    def inspect
      instance_variables = %i[@env @app @command @last_status].map do |symbol|
        "#{symbol}=#{instance_variable_get(symbol)}"
      end
      "#<#{self.class.name}#{instance_variables.join(', ')}>"
    end

    def run_task
      parameters = fetch_configuration
      response = ecs.run_task(parameters)

      unless response.failures.empty?
        raise "Failed to run task: #{response.failures}"
      end

      task = response.tasks.first
      self.task_arn = task.task_arn
      self.last_status = task.last_status

      task
    end

    def describe_task
      return unless task_arn

      response = ecs.describe_tasks({
        cluster: "forms-#{env}",
        tasks: [task_arn],
      })

      failures = response.failures.find_all { |failure| failure.arn == @task_arn }
      unless failures.empty?
        raise "Failed to start task: #{failures}"
      end

      task = response.tasks.first
      self.last_status = task.last_status

      task
    end

  private

    attr_reader :env, :app, :command, :ec2, :ecs
    attr_accessor :last_status, :task_arn

    def fetch_configuration
      forms_vpc = ec2.describe_vpcs({
        filters: [{
          name: "tag:Name",
          values: ["forms-#{env}"],
        }],
      }).vpcs.first

      forms_vpc_security_groups = ec2.describe_security_groups({
        filters: [{
          name: "vpc-id",
          values: [forms_vpc.vpc_id],
        }],
      }).security_groups

      forms_vpc_subnets = ec2.describe_subnets({
        filters: [{
          name: "vpc-id",
          values: [forms_vpc.vpc_id],
        }],
      }).subnets

      private_subnet_ids =
        forms_vpc_subnets
          .map { |subnet| [subnet.tags.find { |tag| tag.key == "Name" }.value, subnet] }.to_h
          .filter { |name, _| name.start_with? "private-" }.values
          .map(&:subnet_id)

      app_security_group_ids =
        forms_vpc_security_groups
          .map { |sg| [sg.group_name, sg] }.to_h
          .fetch_values("default", "forms-rds-#{env}", "forms-#{app}-#{env}")
          .map(&:group_id)

      {
        cluster: "forms-#{env}",
        launch_type: "FARGATE",
        network_configuration: {
          awsvpc_configuration: {
            subnets: private_subnet_ids,
            security_groups: app_security_group_ids,
            assign_public_ip: "DISABLED",
          },
        },
        overrides: {
          container_overrides: [{
            name: "forms-#{app}",
            command:,
          }],
        },
        task_definition: "#{env}_forms-#{app}",
      }
    end
  end
end
