# frozen_string_literal: true

require "aws-sdk-ec2"
require "aws-sdk-ecs"
require "aws-sdk-iam"

require_relative "../utilities/helpers"

class Bastion
  attr_reader :environment

  DATABASES = %w[forms-admin forms-api].freeze
  DEFAULT_COMMAND = "/bin/bash".freeze
  POSTGRES_VERSION = 16

  def initialize(environment)
    @environment = environment

    @ecs = Aws::ECS::Client.new
    @ec2 = Aws::EC2::Client.new
    @iam = Aws::IAM::Client.new
  end

  def apply_configuration
    task_role = safe_get { iam.get_role(role_name: task_role_name).role }
    task_role = iam.create_role(_task_role).role unless task_role
    task_policy = safe_get { iam.get_policy(policy_arn: task_policy_arn).policy }
    task_policy = iam.create_policy(_task_policy).policy unless task_policy
    iam.attach_role_policy(role_name: task_role_name, policy_arn: task_policy_arn)

    execution_role = safe_get { iam.get_role(role_name: execution_role_name).role }
    execution_role = iam.create_role(_execution_role).role unless execution_role
    execution_policy = safe_get { iam.get_policy(policy_arn: execution_policy_arn).policy }
    execution_policy = iam.create_policy(_execution_policy).policy unless execution_policy
    iam.attach_role_policy(role_name: execution_role_name, policy_arn: execution_policy_arn)

    ecs.register_task_definition(_task_definition)
  end

  def teardown_configuration
    safe_delete { iam.detach_role_policy(role_name: execution_role_name, policy_arn: execution_policy_arn) }
    safe_delete { iam.delete_policy(policy_arn: execution_policy_arn) }
    safe_delete { iam.delete_role(role_name: execution_role_name) }

    safe_delete { iam.detach_role_policy(role_name: task_role_name, policy_arn: task_policy_arn) }
    safe_delete { iam.delete_policy(policy_arn: task_policy_arn) }
    safe_delete { iam.delete_role(role_name: task_role_name) }

    ecs.deregister_task_definition(task_definition: task_definition_name)
  end

  def check_configuration!
    task_role = iam.find_role()
  end

  def run(command = DEFAULT_COMMAND)
    check_for_session_manager_plugin!

    ecs.run_task(_task(name)) => { tasks: [{ task_arn: } ] }

    begin
      puts "Waiting for task #{task_arn} to start..."
      ecs.wait_until(:tasks_running, { cluster:, tasks: [task_arn] })
    rescue Aws::Waiters::Errors::FailureStateError => exc
      task = exc.response.tasks.first
      raise "Failed to start container: #{task.stop_code}: #{task.stopped_reason}"
    end

    begin
      sleep(30) # it seems to take a little while for the execute command agent to be ready 🤔

      exec(command, task_arn)
    ensure
      puts "Cleaning up..."
      ecs.stop_task(cluster:, task: task_arn)
    end
  end

  def exec(command = DEFAULT_COMMAND, task)
    # Use AWS CLI so that it can handle the interactivity
    system "aws", "ecs", "execute-command", "--cli-input-json", _execute_command(command, task).to_json, exception: true
  end

  def name
    "#{environment}_bastion"
  end

  def databases
    DATABASES
  end

private

  attr_reader :ec2, :ecs, :iam

  def _execute_command(command = DEFAULT_COMMAND, task)
    {
      cluster:,
      command:,
      interactive: true,
      task:,
    }
  end

  def _task(task_definition)
    {
      cluster: cluster,
      enable_execute_command: true,
      launch_type: "FARGATE",
      task_definition: task_definition_name,
      network_configuration: _task_network_configuration,
    }
  end

  def _task_definition
    {
      family: task_definition_name,
      container_definitions: [{
        name: "psql",
        image: "public.ecr.aws/docker/library/postgres:#{POSTGRES_VERSION}-alpine",
        cpu: 0,
        essential: true,
        command: ["sleep", "3600"],
        linux_parameters: {
          init_process_enabled: true,
        },
        secrets:,
      }],
      task_role_arn: task_role_arn,
      execution_role_arn: execution_role_arn,
      network_mode: "awsvpc",
      cpu: "1024",
      memory: "3072",
      runtime_platform: {
        cpu_architecture: "ARM64",
        operating_system_family: "LINUX",
      },
    }
  end

  def task_definition_name
    name
  end

  def _task_role
    {
      role_name: task_role_name,
      description: "Used by bastion host when running",
      assume_role_policy_document: {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Sid": "AllowECS",
            "Effect": "Allow",
            "Principal": {
              "Service": "ecs-tasks.amazonaws.com",
            },
            "Action": "sts:AssumeRole",
          },
        ],
      }.to_json,
      tags: [
        { key: "Environment", value: environment },
      ],
    }
  end

  def task_role_name
    "#{environment}-bastion-ecs-task"
  end

  def task_role_arn
    "arn:aws:iam::#{account_id}:role/#{task_role_name}"
  end

  def _execution_role
    {
      role_name: execution_role_name,
      description: "Used by ECS to create bastion host task",
      assume_role_policy_document: {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Sid": "AllowECS",
            "Effect": "Allow",
            "Principal": {
              "Service": "ecs-tasks.amazonaws.com",
            },
            "Action": "sts:AssumeRole",
          },
        ],
      }.to_json,
      tags: [
        { key: "Environment", value: environment },
      ],
    }
  end

  def execution_role_name
    "#{environment}-bastion-ecs-task-execution"
  end

  def execution_role_arn
    "arn:aws:iam::#{account_id}:role/#{execution_role_name}"
  end

  def _task_policy
    # From https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html#ecs-exec-required-iam-permissions
    {
      policy_name: task_policy_name,
      policy_document: {
        "Version": "2012-10-17",
        "Statement": [
          "Effect": "Allow",
          "Action": [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel",
          ],
          "Resource": "*",
        ],
      }.to_json,
      description: "Used by bastion host when running",
      tags: [
        { key: "Environment", value: environment },
      ],
    }
  end

  def task_policy_name
    "#{environment}-bastion-ecs-task-policy"
  end

  def task_policy_arn
    "arn:aws:iam::#{account_id}:policy/#{task_policy_name}"
  end

  def _execution_policy
    {
      policy_name: execution_policy_name,
      policy_document: {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Action": "ssm:DescribeParameters",
            "Effect": "Allow",
            "Resource": "*",
          },
          {
            "Action": "ssm:GetParameters",
            "Effect": "Allow",
            "Resource": secrets.map { it[:value_from] },
          },
        ],
      }.to_json,
      tags: [
        { key: "Environment", value: environment },
      ],
    }
  end

  def execution_policy_name
    "#{environment}-bastion-ecs-task-execution-additional"
  end

  def execution_policy_arn
    "arn:aws:iam::#{account_id}:policy/#{execution_policy_name}"
  end

  def secrets
    databases.map do |database|
      {
        name: "#{database.upcase.tr("-", "_")}__DATABASE_URL",
        value_from: "arn:aws:ssm:eu-west-2:#{account_id}:parameter/#{database}-#{environment}/database/url",
      }
    end
  end

  def _task_network_configuration
    @_task_network_configuration ||= build_task_network_configuration
  end

  def build_task_network_configuration
    vpc_id = find_vpc.vpc_id

    # use only private subnets
    subnets = find_private_subnets(vpc_id).map(&:subnet_id)

    # use security groups for apps that normally connect to database
    security_groups = find_security_groups(vpc_id).filter { it.group_name.start_with?(*databases) }.map(&:group_id)

    {
      awsvpc_configuration: {
        security_groups:,
        subnets:,
        assign_public_ip: "DISABLED",
      },
    }
  end

  def find_vpc
    ec2.describe_vpcs(
      filters: [
        { name: "tag:Name", values: ["forms-#{environment}"] },
      ],
    ).vpcs.first
  end

  def find_security_groups(vpc_id)
    ec2.describe_security_groups(
      filters: [
        { name: "vpc-id", values: [vpc_id] },
      ],
    ).security_groups
  end

  def find_subnets(vpc_id)
    ec2.describe_subnets(
      filters: [
        { name: "vpc-id", values: [vpc_id] },
      ],
    ).subnets
  end

  def find_private_subnets(vpc_id)
    find_subnets(vpc_id)
      .filter do |subnet|
        name = subnet.tags.find { |tag| tag.key == "Name" }
        name.value.start_with? "private-"
      end
  end

  def account_id
    @account_id ||= Helpers::ACCOUNT_IDS.invert[environment]
  end

  def cluster
    @cluster ||= "forms-#{environment}"
  end

  def check_for_session_manager_plugin!
    `session-manager-plugin -v`
  rescue Errno::ENOENT
    raise <<~MSG
      Session Manager Plugin for AWS CLI needs to be present to use ECS Exec,
      install it with `brew install session-manager-plugin` or by following the instructions at
      https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html
    MSG
  end

  def safe_get
    yield
  rescue Aws::IAM::Errors::NoSuchEntity
    nil
  end

  def safe_delete(...)
    safe_get(...)
  end
end
