require "concurrent/timer_task"
require "concurrent/map"
require "json"
require "ostruct"
require "sinatra"
require "yaml"

require_relative "lib/aws-sdk-factory/live"
require_relative "lib/aws-sdk-factory/development"

require_relative "lib/models/ArtifactRevision"
require_relative "lib/models/PipelineStage"
require_relative "lib/models/PipelineSummary"

set :public_folder, "public"
helpers do
  def slugify(str)
    return str.downcase
              .gsub(/[ _:\/]/, "-")
  end

  def active_page_css_class?(path)
    request.path_info == path ? "govuk-header__navigation-item--active" : ""
  end
end

is_dev_mode = ENV.fetch("PIPELINE_VISUALISER_DEV_MODE", false)

config = YAML::safe_load_file("./config.yml")
aws_clients = []
config["roles"].each do |role|
  if is_dev_mode
    aws_clients << {
      "client" => DevelopmentAWSSDKFactory.new_code_pipeline(role["role"]),
      "gds_cli_role" => role["gds_cli_role"]
    }
  else
    aws_clients << {
      "client" => LiveAWSSDKFactory.new_code_pipeline(role["role"]),
      "gds_cli_role" => role["gds_cli_role"]
    }
  end
end

pipelines_map = Concurrent::Map.new

task = Concurrent::TimerTask.new(execution_interval: 30, run_now: true) do
  pipelines = []
  aws_clients.each do |client_config|
    begin
      client = client_config["client"]
      all_pipelines = client.list_pipelines
      pipeline_names = all_pipelines.pipelines.map { |p| p.name }

      pipeline_names.each do |pipeline|
        state = client.get_pipeline_state({
                                            name: pipeline
                                          })

        executions = client.list_pipeline_executions({
                                                       pipeline_name: pipeline
                                                     })

        latest_execution_summary = executions.pipeline_execution_summaries
                                             .sort_by { |summary| summary.start_time }
                                             .reverse
                                             .first

        latest_id = latest_execution_summary.pipeline_execution_id

        # To get variables we have to request the pipeline
        # execution with GetPipelineExecution
        latest = client.get_pipeline_execution({
                                                 pipeline_name: pipeline,
                                                 pipeline_execution_id: latest_id
                                               })

        viewdata = generate_pipeline_viewdata(state, latest.pipeline_execution, latest_execution_summary.start_time, client_config["gds_cli_role"])

        pipelines_map[viewdata.name] = viewdata
      rescue => err
        puts err
        puts err.backtrace
      end
    end
  end
end
task.execute

get "/" do
  groups = []
  config["groups"].each do |k, _|
    group_elements = config["groups"][k]
    group = OpenStruct.new
    group.name = k

    group_pipelines = []
    group_elements.map do |elem|
      if pipelines_map.fetch(elem, nil) != nil
        p = pipelines_map[elem]
        group_pipelines << p
      end
    end
    group.pipelines = group_pipelines
    groups << group
  end

  erb :state, :locals => { :groups => groups, :is_dev_mode => is_dev_mode }
end

get "/deploying-changes" do
  erb :deploying_changes
end

def generate_pipeline_viewdata(state, execution, last_start_time, gds_cli_role)
  summary = PipelineSummary.new(state, execution, last_start_time)
  summary.gds_cli_role = gds_cli_role

  summary.variables = execution.variables || []
  summary.artifacts = execution.artifact_revisions.map { |artifact| generate_artifact_viewdata(artifact) }
  summary.stages = state.stage_states.map { |stage| generate_stage_viewdata(stage, summary.execution_id) }


  return summary
end

def generate_artifact_viewdata(artifact)
  return ArtifactRevision.new(artifact)
end

def generate_stage_viewdata(stage, current_execution_id)
  return PipelineStage.new(stage, current_execution_id)
end
