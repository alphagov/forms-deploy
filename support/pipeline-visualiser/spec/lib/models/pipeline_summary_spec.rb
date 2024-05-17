require_relative "../../../lib/models/pipeline_summary"
require "aws-sdk-codepipeline"
require "aws-sdk-codepipeline/types"

describe PipelineSummary do
  let(:codepipeline_state) {
    Aws::CodePipeline::Types::GetPipelineStateOutput.new(
      pipeline_name: "a_pipeline",
      created: Time.now,
      updated: Time.now,
      pipeline_version: 2,
      stage_states: [
        Aws::CodePipeline::Types::StageState.new(
          stage_name: "stage_1",
          latest_execution: Aws::CodePipeline::Types::StageExecution.new(
            pipeline_execution_id: "execution-1",
            status: "Succeeded"
          )
        ),
        Aws::CodePipeline::Types::StageState.new(
          stage_name: "stage_2",
          latest_execution: Aws::CodePipeline::Types::StageExecution.new(
            pipeline_execution_id: "execution-1",
            status: "InProgress"
          )
        ),
        Aws::CodePipeline::Types::StageState.new(
          stage_name: "stage_3",
          latest_execution: Aws::CodePipeline::Types::StageExecution.new(
            pipeline_execution_id: "execution-1",
            status: "Failed"
          ),
          action_states: [
            Aws::CodePipeline::Types::ActionState.new(
              action_name: "action-1",
              latest_execution: Aws::CodePipeline::Types::ActionExecution.new(
                status: "Failed",
                summary: "AN ERROR MESSAGE"
              )
            )
          ]
        )
      ]
    )
  }

  let(:codepipeline_execution) {
    Aws::CodePipeline::Types::PipelineExecution.new(
      pipeline_name: "a_pipeline",
      pipeline_version: 2,
      pipeline_execution_id: "execution-1",
      status: "Succeeded",
      variables: [
        Aws::CodePipeline::Types::ResolvedPipelineVariable.new(
          name: "Variable",
          resolved_value: "Some string value"
        )
      ],
      artifact_revisions: [
        Aws::CodePipeline::Types::ArtifactRevision.new(
          name: "get-source",
          revision_id: "012abc",
          revision_summary: '{"ProviderType": "GitHub", "CommitMessage": "Some headline text\n\nFollowed by a bit more text which describes it in more detail"}'
        )
      ]
    )
  }

  let(:last_start_at) {
    Date.parse("2024-04-01T00:00:00")
  }

  subject {
    PipelineSummary.new(codepipeline_state, codepipeline_execution, last_start_at)
  }

  it "name comes from the name in the pipeline state" do
    expect(subject.name).to eq "a_pipeline"
  end

  it "execution id comes from the id of the current execution" do
    expect(subject.execution_id).to eq "execution-1"
  end

  it "last start time comes from the paased-in start time" do
    expect(subject.last_started_at).to eq last_start_at
  end

  it "status comes from the status of the current execution" do
    expect(subject.status).to eq "Succeeded"
  end

  it "artifacts is an empty array" do
    expect(subject.artifacts).to eq []
  end

  it "stages is an empty array" do
    expect(subject.stages).to eq []
  end

  describe "when there are no variables" do
    it "variables is an empty hash" do
      codepipeline_execution.variables = []
      subject = PipelineSummary.new(codepipeline_state, codepipeline_execution, last_start_at)

      expect(subject.variables).to eq({})
    end
  end

  describe "when there are variables" do
    it "converts them in to a hash" do
      expected_hash = {
        "Variable" => "Some string value"
      }
      expect(subject.variables).to eq expected_hash
    end
  end

  describe "is_running" do
    %w[InProgress Stopping].each do |status|
      it "is true when the execution status is '#{status}'" do
        codepipeline_execution.status = status
        expect(subject.is_running?).to be_truthy
      end
    end

    %w[Cancelled Stopped Succeeded Superseded Failed].each do |status|
      it "is false when the execution status is '#{status}'" do
        codepipeline_execution.status = status
        expect(subject.is_running?).to be_falsey
      end
    end
  end

  context "when in a non-running state" do
    it "running_duration is nil" do
      codepipeline_execution.status = "Succeeded"
      expect(subject.running_duration).to be_nil
    end

    it "current_stage_name is nil" do
      codepipeline_execution.status = "Succeeded"
      expect(subject.current_stage_name).to be_nil
    end
  end

  context "when in a running state" do
    let(:last_start_at){
      DateTime.now - (2/24.0) # 2 hours ago
    }

    before do
      codepipeline_execution.status = "InProgress"
    end

    it "running_duration is a duration between now and the last_started_at time" do
      duration = subject.running_duration
      expect(duration.in_hours).to eq 2
    end

    it "current_stage_name is the name of the first stage in the current execution with the status 'InProgress'" do
      expect(subject.current_stage_name).to eq "stage_2"
    end
  end

  context "in a failing state" do
    before do
      codepipeline_execution.status = "Failed"
    end

    it "first_failing_stage_name is the name of the first stage with the Failed status" do
      expect(subject.first_failing_stage_name).to eq "stage_3"
    end

    it "first_failing_stage_error_message is the error message coming from the first failing stage" do
      expect(subject.first_failing_stage_error_message).to eq "AN ERROR MESSAGE"
    end
  end
end
