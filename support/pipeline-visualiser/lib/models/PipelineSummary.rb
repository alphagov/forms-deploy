require 'active_support'
require 'active_support/duration'

class PipelineSummary
  attr_accessor :name
  attr_accessor :execution_id
  attr_accessor :last_started_at
  attr_accessor :status
  attr_accessor :gds_cli_role
  attr_accessor :variables
  attr_accessor :artifacts
  attr_accessor :stages
  attr_accessor :running_duration
  attr_accessor :current_stage_name


  # @param [Aws::CodePipeline::Types::GetPipelineStateOutput] codepipeline_state
  # @param [Aws::CodePipeline::Types::PipelineExecutionSummary] codepipeline_execution
  # @param [Date] last_started_at
  def initialize(codepipeline_state, codepipeline_execution, last_started_at)
    @name = codepipeline_state.pipeline_name
    @execution_id = codepipeline_execution.pipeline_execution_id
    @last_started_at = last_started_at
    @status = codepipeline_execution.status

    vars = codepipeline_execution.variables || []
    @variables = vars.map {|var| [var.name, var.resolved_value]}.to_h
    @artifacts = []
    @stages = []

    if !is_running?
      @running_duration = nil
    else
      now_seconds = DateTime.now.to_time.to_i
      last_start_seconds = @last_started_at.to_time.to_i
      @running_duration = ActiveSupport::Duration.build(now_seconds - last_start_seconds)

      codepipeline_state.stage_states.each do |stage|
        if stage.latest_execution.pipeline_execution_id == @execution_id && stage.latest_execution.status == "InProgress" then
          @current_stage_name = stage.stage_name
        end
      end
    end
  end

  def is_running?
    %w[InProgress Stopping].include? @status
  end
end