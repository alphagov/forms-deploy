require "sinatra"
require "aws-sdk-codepipeline"
require "ostruct"
require "json"

set :public_folder, "public"

codepipeline = Aws::CodePipeline::Client.new(region: "eu-west-2")

get "/" do
    all_pipelines = codepipeline.list_pipelines()
    pipeline_names = all_pipelines.pipelines.map {|p| p.name}

    pipelines = []
    pipeline_names.each do |pipeline|
        state = codepipeline.get_pipeline_state({
            name: pipeline
        })

        executions = codepipeline.list_pipeline_executions({
            pipeline_name: pipeline
        })

        latest_execution_summary = executions.pipeline_execution_summaries
            .sort_by{ |summary| summary.start_time }
            .reverse
            .first

        latest_id = latest_execution_summary.pipeline_execution_id

        # To get variables we have to request the pipeline
        # execution with GetPipelineExecution
        latest = codepipeline.get_pipeline_execution({
            pipeline_name: pipeline,
            pipeline_execution_id: latest_id
        })

        pipelines << generate_pipeline_viewdata(state, latest.pipeline_execution, latest_execution_summary.start_time)
    end

    erb :state, :locals => {:pipelines => pipelines}
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
