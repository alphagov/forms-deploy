# frozen_string_literal: true

require "commands/pipeline_summary"
require_relative "../fixtures/codepipeline"

describe PipelineSummary do
  context "when not authenticated" do
    it "prompts the user to authenticate" do
      expect { described_class.new.run }.to output(/You must be authenticated/).to_stdout
    end

    context "when authenticated" do
      let(:printer_mock) do
        printer_mock = instance_double(Printer)

        allow(printer_mock)
          .to receive(:print_table)

        printer_mock
      end

      before do
        allow_any_instance_of(Helpers) # rubocop:todo RSpec/AnyInstance
          .to receive(:aws_authenticated?)
          .and_return(true)

        allow(Printer)
          .to receive(:new)
          .and_return(printer_mock)

        codepipeline_stub = instance_double(Aws::CodePipeline::Client)
        allow(Aws::CodePipeline::Client)
          .to receive(:new)
          .and_return(codepipeline_stub)

        allow(codepipeline_stub)
          .to receive(:list_pipelines)
          .and_return(CodePipelineFixtures.list_pipelines)

        allow(codepipeline_stub)
          .to receive(:get_pipeline_state)
          .and_return(CodePipelineFixtures.get_pipeline_state)
      end

      it "prints all of the pipeline summaries" do
        expected_actions = [
          { stage_name: "stage-one",
            action_name: "action-one",
            status: "Succeeded",
            time: Time.parse("2023-01-01 00:00:00 +0000") },
          { stage_name: "stage-one",
            action_name: "action-two",
            status: "Succeeded",
            time: Time.parse("2023-01-01 00:00:00 +0000") },
          { stage_name: "stage-two",
            action_name: "action-one",
            status: "Succeeded",
            time: Time.parse("2023-01-01 00:00:00 +0000") },
        ]
        described_class.new.run

        expect(printer_mock)
          .to have_received(:print_table)
          .with(/pipeline-*/, expected_actions)
          .exactly(3).times
      end

      it "filters pipelines" do
        stub_const("ARGV", ["--filter", "pipeline-one"])
        described_class.new.run

        expect(printer_mock)
          .to have_received(:print_table)
          .with("pipeline-one", anything)
      end
    end
  end
end
