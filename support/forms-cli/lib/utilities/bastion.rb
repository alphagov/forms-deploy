# frozen_string_literal: true

require "json"

require "aws-sdk-ecs"

require_relative "../utilities/helpers"

class Bastion
  attr_reader :environment

  DATABASES = %w[forms-admin forms-api].freeze
  DEFAULT_COMMAND = "/bin/bash"
  DEFAULT_CONTAINER_IMAGE = "public.ecr.aws/docker/library/postgres:16-alpine"

  def initialize(environment)
    @environment = environment

    @ecs = Aws::ECS::Client.new
  end

  def setup(container_image: nil)
    container_image ||= DEFAULT_CONTAINER_IMAGE

    puts "Using terraform to setup configuration for bastion host..."
    terraform_init "-reconfigure"
    terraform_apply(container_image:)
  end

  def teardown
    puts "Using terraform to teardown configuration for bastion host..."
    terraform_destroy
  end

  def start(wait: true)
    response = ecs.run_task(task_configuration) => { tasks: [{ task_arn: }] }
    @task_arn = response.tasks.first.task_arn
    wait_until_running if wait
  end

  def wait_until_running
    start unless @task_arn
    info "Waiting for task #{@task_arn} to start..."
    ecs.wait_until(:tasks_running, { cluster:, tasks: [@task_arn] })
  rescue Aws::Waiters::Errors::FailureStateError => e
    task = e.response.tasks.first
    raise "Failed to start container: #{task.stop_code}: #{task.stopped_reason}"
  end

  def stop
    ecs.stop_task(cluster:, task: @task_arn)
  end

  def exec(command = DEFAULT_COMMAND)
    check_for_session_manager_plugin!
    # Use AWS CLI so that it can handle the interactivity
    args = { cluster:, command:, interactive: true, task: @task_arn }
    system "aws", "ecs", "execute-command", "--cli-input-json", args.to_json, exception: true
  end

  def run(command: DEFAULT_COMMAND)
    check_for_session_manager_plugin!

    start

    begin
      sleep(30) # it seems to take a little while for the execute command agent to be ready 🤔

      exec(command)
    ensure
      info "Cleaning up..."
      stop
    end
  end

  def databases
    @databases ||= DATABASES
  end

  def task_configuration
    @task_configuration ||= get_task_configuration
  end

private

  attr_reader :ecs

  include Helpers

  def terraform(subcommand, *args)
    if args.last.is_a? Hash
      options = args.pop.dup
    else
      options = {}
    end

    tf_env = { "TF_IN_AUTOMATION" => "true", "TF_INPUT" => "false" }
    tf_module_dir = forms_cli_dir.join("lib/terraform_modules/bastion")
    tf_global_flags = ["-chdir=#{tf_module_dir}"]

    system tf_env, "terraform", *tf_global_flags, subcommand, *args, exception: true, **options
  end

  def terraform_init(*args)
    backend_config_file = infra_dir.join("deployments/forms/account/tfvars/backends/#{environment}.tfvars")
    args.prepend("-backend-config=#{backend_config_file}", "-var=environment=#{environment}", "-var=account_id=#{account_id}")
    terraform "init", *args
  end

  def terraform_apply(container_image:)
    var_flags = [
      "-var=environment=#{environment}", "-var=account_id=#{account_id}",
      "-var=databases=#{databases}", "-var=container_image=#{container_image}",
    ]

    terraform "apply", *var_flags
  end

  def terraform_destroy
    terraform "destroy"
  end

  def terraform_output(variable_name)
    out_r, out_w = IO.pipe
    terraform "output", "-json", variable_name, out: out_w

    out_w.close
    JSON.parse(out_r.read, symbolize_names: true)
  end

  def get_task_configuration
    terraform_init out: File::NULL
    terraform_output("task_configuration")
  rescue RuntimeError
    abort "Could not get task configuration from Terraform: try running `forms bastion_exec --setup`"
  end

  def account_id
    @account_id ||= Helpers::ACCOUNT_IDS.invert[environment]
  end

  def cluster
    @cluster ||= "forms-#{environment}"
  end

  def check_for_session_manager_plugin!
    @has_session_manager_plugin ||= !!`session-manager-plugin --version`
  rescue Errno::ENOENT
    raise <<~MSG
      Session Manager Plugin for AWS CLI needs to be present to use ECS Exec,
      install it with `brew install session-manager-plugin` or by following the instructions at
      https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html
    MSG
  end

  def info(message)
    $stderr.puts message
  end
end
