require_relative '../../../lib/models/PipelineStage'
require "aws-sdk-codepipeline"
require "aws-sdk-codepipeline/types"

describe PipelineStage do

  let(:codepipeline_stage){
    Aws::CodePipeline::Types::StageState.new(
      stage_name: "stage_name",
      latest_execution: Aws::CodePipeline::Types::StageExecution.new(
        pipeline_execution_id: "execution-2",
        status: "Failed"
      ),
      action_states: [
        Aws::CodePipeline::Types::ActionState.new(
          action_name: "action-1",
          latest_execution: Aws::CodePipeline::Types::ActionExecution.new(
            status: "Succeeded",
          )
        ),
        Aws::CodePipeline::Types::ActionState.new(
          action_name: "action-2",
          latest_execution: Aws::CodePipeline::Types::ActionExecution.new(
            status: "Failed",
            summary: "action error message"
          )
        )
      ]
    )
  }

  subject {
    PipelineStage.new(codepipeline_stage, "execution-1")
  }


  it "name comes from the name of the CodePipeline stage stage_name" do
    expect(subject.name).to eq "stage_name"
  end

  it "status comes from the latest execution status" do
    expect(subject.status).to eq "Failed"
  end

  it "is outdated if the current execution id is not the same as the latest" do
    expect(subject.outdated).to be true
  end

  it "is not outdated if the current execution id matches the latest execution id" do
    subject = PipelineStage.new(codepipeline_stage, "execution-2")
    expect(subject.outdated).to be false
  end

  describe "when stage state not Failed" do
    it "error message is nil" do
      codepipeline_stage.latest_execution.status = "Succeeded"
      subject = PipelineStage.new(codepipeline_stage, "execution-1")

      expect(subject.error_message).to be_nil
    end
  end

  describe "when stage state is Failed" do
    it "error message comes from the first failed action" do
      expect(subject.error_message).to eq "action error message"
    end
  end
end