class PipelineSummary
  attr_accessor :name
  attr_accessor :execution_id
  attr_accessor :last_started_at
  attr_accessor :status
  attr_accessor :gds_cli_role
  attr_accessor :variables
  attr_accessor :artifacts
  attr_accessor :stages

  # @param [Aws::CodePipeline::Types::GetPipelineStateOutput] codepipeline_state
  # @param [Aws::CodePipeline::Types::PipelineExecutionSummary] codepipeline_execution
  # @param [Date] last_started_at
  def initialize(codepipeline_state, codepipeline_execution, last_started_at)
    @name = codepipeline_state.pipeline_name
    @execution_id = codepipeline_execution.pipeline_execution_id
    @last_started_at = last_started_at
    @status = codepipeline_execution.status

    @variables = []
    @artifacts = []
    @stages = []
  end
end