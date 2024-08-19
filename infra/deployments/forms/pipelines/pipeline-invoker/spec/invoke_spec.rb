require "json"
require "aws-sdk-codepipeline"
require "logger"
require "spec_helper"

require_relative "../invoke"

describe PipelineInvoker::Handler do
  let(:pipeline_invoker) { described_class.new }
  let(:codepipeline_client) { instance_double(Aws::CodePipeline::Client) }
  let(:logger) { instance_double(Logger) }
  let(:pipeline_name) { "PIPELINE_TO_INVOKE" }
  let(:container_image_uri) { "CONTAINER_IMAGE_URI" }
  let(:event) do
    {
      "client_request_token" => "some_token",
      "name" => pipeline_name,
      "variables" => [
        {
          "name" => "container_image_uri",
          "value" => container_image_uri,
        },
      ],
      "sourceRevisions" => [
        {
          "actionName" => "some_action",
          "revisionType" => "some_revision_type",
          "revisionValue" => "some_revision_value",
        },
      ],
    }
  end

  before do
    allow(Aws::CodePipeline::Client).to receive(:new).and_return(codepipeline_client)
  end

  describe "#process" do
    it "initializes payload with the correct name from event" do
      payload = {}
      payload["name"] = event["name"]

      expect(payload["name"]).to eq(pipeline_name)
    end

    it "populates payload['variables'] when event['variables'] is not nil" do
      payload = {}
      payload["variables"] = []

      unless event["variables"].nil?
        event["variables"].each do |var|
          payload["variables"] << {
            name: var["name"],
            value: var["value"],
          }
        end
      end

      expect(payload["variables"]).to eq([
        { name: "container_image_uri", value: container_image_uri },
      ])
    end

    it "sets payload['variables'] to an empty array when event['variables'] is nil" do
      event_with_nil_variables = { "name" => pipeline_name, "variables" => nil }

      payload = {}
      payload["variables"] = []

      unless event_with_nil_variables["variables"].nil?
        event_with_nil_variables["variables"].each do |variable|
          payload["variables"] << {
            name: variable["name"],
            value: variable["value"],
          }
        end
      end

      expect(payload["variables"]).to eq([])
    end

    it "initializes payload with the correct sourceRevisions from event" do
      payload = {}
      payload["sourceRevisions"] = event["sourceRevisions"]

      expect(payload["sourceRevisions"]).to eq([{ "actionName" => "some_action", "revisionType" => "some_revision_type", "revisionValue" => "some_revision_value" }])
    end

    it "populates payload['sourceRevisions'] when event['sourceRevisions'] is not nil" do
      payload = {}
      payload["sourceRevisions"] = []

      unless event["sourceRevisions"].nil?
        event["sourceRevisions"].each do |revision|
          payload["sourceRevisions"] << {
            action_name: revision["actionName"],
            revision_type: revision["revisionType"],
            revision_value: revision["revisionValue"],
          }
        end
      end

      expect(payload["sourceRevisions"]).to eq([{
        action_name: "some_action",
        revision_type: "some_revision_type",
        revision_value: "some_revision_value",
      }])
    end

    it "sets payload['sourceRevisions'] to an empty array when event['sourceRevisions'] is nil" do
      event_with_nil_source_revisions = { "name" => pipeline_name, "sourceRevisions" => nil }

      payload = {}
      payload["sourceRevisions"] = []

      unless event_with_nil_source_revisions["sourceRevisions"].nil?
        event_with_nil_source_revisions["sourceRevisions"].each do |revision|
          payload["sourceRevisions"] << {
            action_name: revision["actionName"],
            revision_type: revision["revisionType"],
            revision_value: revision["revisionValue"],
          }
        end
      end

      expect(payload["sourceRevisions"]).to eq([])
    end

    it "creates an Aws::CodePipeline::Client with the correct region" do
      expect(Aws::CodePipeline::Client).to receive(:new).with(region: "eu-west-2").and_return(codepipeline_client)
      expect(codepipeline_client).to receive(:start_pipeline_execution)

      pipeline_invoker.process(event:, context: double("context"))
    end

    it "invokes the AWS CodePipeline API with correct parameters" do
      expected_params = {
        client_request_token: "some_token",
        name: pipeline_name,
        source_revisions: [
          {
            action_name: "some_action",
            revision_type: "some_revision_type",
            revision_value: "some_revision_value",
          },
        ],
        variables: [
          {
            name: "container_image_uri",
            value: container_image_uri,
          },
        ],
      }

      expect(codepipeline_client).to receive(:start_pipeline_execution).with(expected_params)

      pipeline_invoker.process(event:, context: double("context"))
    end
  end
end
