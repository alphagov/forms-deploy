# frozen_string_literal: true

class PausedPipelineDetector
  # @param [Aws::CodePipeline::Client] codepipeline_client
  # @param [int] paused_duration_threshold_hours
  # @return [Array<Aws::CodePipeline::Types::GetPipelineStateOutput>]
  def self.find_paused_pipelines(codepipeline_client, paused_duration_threshold_hours)
    threshold_timestamp = Time.at(Time.now - (60 * 60 * paused_duration_threshold_hours))

    all_pipelines = codepipeline_client.list_pipelines

    all_pipelines.pipelines
      .map { |pipeline| codepipeline_client.get_pipeline_state(name: pipeline.name) }
      .filter { |state| has_any_paused_stages(state, threshold_timestamp) }
  end

  # @param [Array<Aws::CodePipeline::Types::StageState>] stages
  def self.longest_paused_stage(stages)
    stages
      .filter { |stage| stage_is_disabled(stage) }
      .min_by { |stage| stage.inbound_transition_state.last_changed_at }
  end

  def self.has_any_paused_stages(pipeline_state, threshold_timestamp)
    pipeline_state.stage_states.any? do |stage|
      stage_is_disabled(stage) &&
        stage_last_disabled_before(stage, threshold_timestamp)
    end
  end

  def self.stage_is_disabled(stage)
    !stage.inbound_transition_state.enabled
  end

  def self.stage_last_disabled_before(stage, timestamp)
    stage.inbound_transition_state.last_changed_at < timestamp
  end
end
