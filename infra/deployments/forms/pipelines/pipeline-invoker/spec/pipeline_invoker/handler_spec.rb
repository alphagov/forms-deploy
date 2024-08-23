require "json"
require "aws-sdk-codepipeline"
require "logger"
require "spec_helper"

require_relative "../../pipeline_invoker"

describe "#process" do
  let(:codepipeline_client) { instance_double(Aws::CodePipeline::Client) }
  let(:logger) { instance_double(Logger) }
  let(:pipeline_name) { "PIPELINE_TO_INVOKE" }
  let(:container_image_uri) { "CONTAINER_IMAGE_URI" }
  let(:context) { double("context") } # rubocop:disable RSpec/VerifiedDoubles
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

  it "creates an Aws::CodePipeline::Client with the correct region" do
    allow(Aws::CodePipeline::Client).to receive(:new).with(region: "eu-west-2").and_return(codepipeline_client)
    expect(codepipeline_client).to receive(:start_pipeline_execution)

    process(event:, context:)
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

    process(event:, context:)
  end

  it "handles AWS CodePipeline API failures by raising an error" do
    error = Aws::CodePipeline::Errors::ServiceError.new(nil, "A generic ServiceError")
    allow(Logger).to receive(:new).and_return(logger)
    allow(codepipeline_client).to receive(:start_pipeline_execution).and_raise(error)

    expected_log_entry = {
      level: "error",
      message: "AWS CodePipeline API error occurred",
      error_type: error.class.to_s,
      error_message: "A generic ServiceError",
      pipeline_name:,
      context: {
        region: "eu-west-2",
        event_details: event,
      },
    }.to_json

    expect(logger).to receive(:info)
    expect(logger).to receive(:error).with(expected_log_entry)

    expect { process(event:, context:) }.to raise_error(Aws::CodePipeline::Errors::ServiceError)
  end

  describe "#build_payload" do
    it "initializes payload with the correct name from event" do
      payload = build_payload(event)

      expect(payload["name"]).to eq(pipeline_name)
    end

    it "populates payload['variables'] when event['variables'] is not nil" do
      payload = build_payload(event)

      expect(payload["variables"]).to eq([
        { name: "container_image_uri", value: container_image_uri },
      ])
    end

    it "sets payload['variables'] to an empty array when event['variables'] is nil" do
      event_with_nil_variables = { "name" => pipeline_name, "variables" => nil }

      payload = build_payload(event_with_nil_variables)

      expect(payload["variables"]).to eq([])
    end

    it "sets payload['sourceRevisions'] when event['sourceRevisions'] is not nil" do
      payload = build_payload(event)

      expect(payload["source_revisions"]).to eq([{
        action_name: "some_action",
        revision_value: "some_revision_value",
        revision_type: "some_revision_type",
      }])
    end

    it "sets payload['sourceRevisions'] to an empty array when event['sourceRevisions'] is nil" do
      event_with_nil_source_revisions = {
        "name" => pipeline_name,
        "variables" => nil,
        "sourceRevisions" => nil,
      }

      payload = build_payload(event_with_nil_source_revisions)

      expect(payload["source_revisions"]).to eq([])
    end
  end
end
