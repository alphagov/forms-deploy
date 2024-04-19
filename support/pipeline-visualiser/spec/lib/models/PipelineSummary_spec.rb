require_relative '../../../lib/models/PipelineSummary'
require "aws-sdk-codepipeline"
require "aws-sdk-codepipeline/types"

describe PipelineSummary do
  let(:codepipeline_state) {
    Aws::CodePipeline::Types::GetPipelineStateOutput.new(
      pipeline_name: "a_pipeline",
      created: Time.now,
      updated: Time.now,
      pipeline_version: 2
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

  subject{
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
end