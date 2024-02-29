require "sinatra"
require "aws-sdk-codepipeline"
require "ostruct"
require "json"
require "YAML"

set :public_folder, "public"
helpers do
    def slugify(str)
        return str.downcase
            .gsub(/[ _:\/]/, "-")
    end
end

config = YAML::safe_load_file("./config.yml")
aws_clients = []
config["roles"].each do |role_arn|
    aws_clients << Aws::CodePipeline::Client.new(
        credentials: Aws::AssumeRoleCredentials.new(
            role_arn: role_arn,
            role_session_name: "govuk_forms_codepipeline_visualiser"
        ),
        region: "eu-west-2"
    )
end


get "/" do
    pipelines = []
    aws_clients.each do |client|

        all_pipelines = client.list_pipelines()
        pipeline_names = all_pipelines.pipelines.map {|p| p.name}

        pipeline_names.each do |pipeline|
            state = client.get_pipeline_state({
                name: pipeline
            })

            executions = client.list_pipeline_executions({
                pipeline_name: pipeline
            })

            latest_execution_summary = executions.pipeline_execution_summaries
                .sort_by{ |summary| summary.start_time }
                .reverse
                .first

            latest_id = latest_execution_summary.pipeline_execution_id

            # To get variables we have to request the pipeline
            # execution with GetPipelineExecution
            latest = client.get_pipeline_execution({
                pipeline_name: pipeline,
                pipeline_execution_id: latest_id
            })

            pipelines << generate_pipeline_viewdata(state, latest.pipeline_execution, latest_execution_summary.start_time)
        end
    end

    pipelines_map = pipelines.to_h {|p| [p.name, p]}

    groups = []
    config["groups"].each do |k, _|
        group_elements = config["groups"][k]
        group = OpenStruct.new
        group.name = k

        group_pipelines = []
        group_elements.map do |elem|
            if pipelines_map.has_key?(elem)
                p = pipelines_map.fetch(elem)
                group_pipelines << p
            end
        end

        group.pipelines = group_pipelines
        groups << group
    end

    erb :state, :locals => {:groups => groups}
end

def generate_pipeline_viewdata(state, execution, last_start_time)
    name = state.pipeline_name
    exec_id = execution.pipeline_execution_id
    overall_status = execution.status
    variables = execution.variables || []

    artifacts = execution.artifact_revisions.map {|artifact| generate_artifact_viewdata(artifact)}
    stages = state.stage_states.map {|stage| generate_stage_viewdata(stage, exec_id)}

    data = OpenStruct.new
    data.name = name
    data.execution_id = exec_id
    data.last_started_at = last_start_time
    data.status = overall_status
    data.variables = variables
    data.artifacts = artifacts
    data.stages = stages

    return data
end

def generate_artifact_viewdata(artifact)
    data = OpenStruct.new
    data.name = artifact.name
    data.revision_id = artifact.revision_id

    if artifact.revision_summary.start_with? "{"
        # It's probably a Git source
        summary_json = JSON.parse(artifact.revision_summary)

        summary_text = ""
        case summary_json["ProviderType"]
        when "GitHub", "CodeCommit"
            summary_text = summary_json["CommitMessage"]
        else
            summary_text = "Error: Unknown provider type"
        end

        data.revision_summary = summary_text
    else
        data.revision_summary = artifact.revision_summary
    end

    return data
end

def generate_stage_viewdata(stage, current_execution_id)
    is_outdated = stage.latest_execution.pipeline_execution_id != current_execution_id

    data = OpenStruct.new
    data.name = stage.stage_name
    data.status = stage.latest_execution.status
    data.outdated = is_outdated

    return data
end
