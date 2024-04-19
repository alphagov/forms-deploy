class PipelineStage
  attr_accessor :name
  attr_accessor :status
  attr_accessor :outdated
  attr_accessor :error_message

  # @param [Aws::CodePipeline::Types::StageState] codepipeline_stage
  # @param [string] current_execution_id
  def initialize(codepipeline_stage, current_execution_id)
    @name = codepipeline_stage.stage_name
    @status = codepipeline_stage.latest_execution.status
    @outdated = codepipeline_stage.latest_execution.pipeline_execution_id != current_execution_id

    if @status == "Failed" then
      failing_action = codepipeline_stage.action_states.find do |action|
        action.latest_execution&.status == "Failed"
      end

      if failing_action != nil
        if failing_action.latest_execution&.error_details&.message
          @error_message = failing_action.latest_execution.error_details.message
        elsif failing_action.latest_execution&.summary
          @error_message = failing_action.latest_execution.summary
        end
      end
    end
  end
end