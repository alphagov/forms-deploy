require "aws-sdk-codepipeline"
require "aws-sdk-codepipeline/types"

require_relative "../../lib/paused_pipeline_detector"

def pipelines(client, pipeline_name_to_state_map)
  client.stub_responses(
    :list_pipelines,
    Aws::CodePipeline::Types::ListPipelinesOutput.new(
      pipelines: pipeline_name_to_state_map.keys.map do |pipeline_name|
        Aws::CodePipeline::Types::PipelineSummary.new(name: pipeline_name)
      end,
    ),
  )

  client.stub_responses(
    :get_pipeline_state,
    lambda { |context|
      name = context.params[:name]
      pipeline_name_to_state_map[name]
    },
  )

  client
end

describe PausedPipelineDetector do
  let(:faked_code_pipeline_client) do
    Aws::CodePipeline::Client.new(stub_responses: true)
  end

  describe "find_paused_pipelines" do
    context "when there are no pipelines" do
      let(:faked_code_pipeline_client) do
        pipelines Aws::CodePipeline::Client.new(stub_responses: true), {}
      end

      it "finds no pipelines that are paused" do
        pipelines = described_class.find_paused_pipelines(faked_code_pipeline_client, 24)
        expect(pipelines).to eq([])
      end
    end

    context "when there are pipelines but none of them are paused" do
      let(:faked_code_pipeline_client) do
        pipelines Aws::CodePipeline::Client.new(stub_responses: true), {
          "pipeline_a" => Aws::CodePipeline::Types::GetPipelineStateOutput.new(
            pipeline_name: "pipeline_a",
            created: Time.now,
            updated: Time.now,
            pipeline_version: 2,
            stage_states: [],
          ),
        }
      end

      it "finds no pipelines that are paused" do
        pipelines = described_class.find_paused_pipelines(faked_code_pipeline_client, 24)
        expect(pipelines).to eq([])
      end
    end

    context "when there is one pipeline which has been paused for 36 hours" do
      let(:faked_code_pipeline_client) do
        pipelines Aws::CodePipeline::Client.new(stub_responses: true), {
          "pipeline_a" => Aws::CodePipeline::Types::GetPipelineStateOutput.new(
            pipeline_name: "pipeline_a",
            created: Time.now,
            updated: Time.now,
            pipeline_version: 2,
            stage_states: [
              Aws::CodePipeline::Types::StageState.new(
                stage_name: "stage_1",
                inbound_transition_state: Aws::CodePipeline::Types::TransitionState.new(
                  enabled: false,
                  last_changed_at: Time.at(Time.now.to_i - (60 * 60 * 36)),
                  disabled_reason: "I paused it",
                ),
              ),
            ],
          ),
        }
      end

      it "finds no pipelines when the threshold is 48 hours" do
        pipelines = described_class.find_paused_pipelines(faked_code_pipeline_client, 48)
        expect(pipelines).to eq([])
      end

      it "finds one pipeline when the threshold is 24 hours" do
        pipelines = described_class.find_paused_pipelines(faked_code_pipeline_client, 24)

        expect(pipelines.length).to eq 1
        expect(pipelines[0].pipeline_name).to eq "pipeline_a"
      end
    end

    context "when there are two pipelines, one un-paused and one paused for 36 hours" do
      let(:faked_code_pipeline_client) do
        pipelines Aws::CodePipeline::Client.new(stub_responses: true), {
          "pipeline_a" => Aws::CodePipeline::Types::GetPipelineStateOutput.new(
            pipeline_name: "pipeline_a",
            created: Time.now,
            updated: Time.now,
            pipeline_version: 2,
            stage_states: [
              Aws::CodePipeline::Types::StageState.new(
                stage_name: "stage_1",
                inbound_transition_state: Aws::CodePipeline::Types::TransitionState.new(
                  enabled: true,
                ),
              ),
            ],
          ),
          "pipeline_b" => Aws::CodePipeline::Types::GetPipelineStateOutput.new(
            pipeline_name: "pipeline_b",
            created: Time.now,
            updated: Time.now,
            pipeline_version: 2,
            stage_states: [
              Aws::CodePipeline::Types::StageState.new(
                stage_name: "stage_1",
                inbound_transition_state: Aws::CodePipeline::Types::TransitionState.new(
                  enabled: false,
                  last_changed_at: Time.at(Time.now.to_i - (60 * 60 * 36)),
                  disabled_reason: "I paused it",
                ),
              ),
            ],
          ),
        }
      end

      it "finds no pipelines when the threshold is 48 hours" do
        pipelines = described_class.find_paused_pipelines(faked_code_pipeline_client, 48)
        expect(pipelines).to eq([])
      end

      it "finds one pipeline when the threshold is 24 hours" do
        pipelines = described_class.find_paused_pipelines(faked_code_pipeline_client, 24)

        expect(pipelines.length).to eq 1
        expect(pipelines[0].pipeline_name).to eq "pipeline_b"
      end
    end
  end

  describe "longest_paused_stage" do
    let(:stages) {}

    context "when there are no stages" do
      let(:stages) { [] }

      it "returns nil" do
        longest = described_class.longest_paused_stage(stages)
        expect(longest).to be_nil
      end
    end

    context "when there are no paused staged" do
      let(:stages) do
        [
          Aws::CodePipeline::Types::StageState.new(
            stage_name: "stage_1",
            inbound_transition_state: Aws::CodePipeline::Types::TransitionState.new(
              enabled: true,
            ),
          ),
        ]
      end

      it "returns nil" do
        longest = described_class.longest_paused_stage(stages)
        expect(longest).to be_nil
      end
    end

    context "when there is only one paused stage" do
      let(:stages) do
        [
          Aws::CodePipeline::Types::StageState.new(
            stage_name: "stage_1",
            inbound_transition_state: Aws::CodePipeline::Types::TransitionState.new(
              enabled: false,
              last_changed_at: Time.now,
            ),
          ),
        ]
      end

      it "returns the paused stage" do
        longest = described_class.longest_paused_stage(stages)
        expect(longest).to eq stages[0]
      end
    end

    context "when there are multiple stages paused at different times" do
      let(:stages) do
        [
          Aws::CodePipeline::Types::StageState.new(
            stage_name: "stage_1",
            inbound_transition_state: Aws::CodePipeline::Types::TransitionState.new(
              enabled: false,
              last_changed_at: Time.at(Time.now.to_i - (60 * 60 * 36)), # 36 hours
            ),
          ),
          Aws::CodePipeline::Types::StageState.new(
            stage_name: "stage_2",
            inbound_transition_state: Aws::CodePipeline::Types::TransitionState.new(
              enabled: false,
              last_changed_at: Time.at(Time.now.to_i - (60 * 60 * 48)), # 48 hours
            ),
          ),
          Aws::CodePipeline::Types::StageState.new(
            stage_name: "stage_3",
            inbound_transition_state: Aws::CodePipeline::Types::TransitionState.new(
              enabled: false,
              last_changed_at: Time.at(Time.now.to_i - (60 * 60 * 12)), # 12 hours
            ),
          ),
        ]
      end

      it "returns the stage which as been paused the longest" do
        longest = described_class.longest_paused_stage(stages)
        expect(longest).to eq stages[1]
      end
    end
  end
end
