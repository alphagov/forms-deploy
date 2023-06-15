# frozen_string_literal: true

require "aws-sdk-codepipeline"
require "time"

# Fixtures for CodePipeline
module CodePipelineFixtures
  @codepipeline_client_stub = Aws::CodePipeline::Client.new({ stub_responses: true })

  def self.list_pipelines
    @codepipeline_client_stub.stub_data(
      :list_pipelines,
      { pipelines: [{ name: "pipeline-one",
                      version: 6,
                      created: Time.parse("2023-01-01"),
                      updated: Time.parse("2023-01-01") },
                    { name: "pipeline-two",
                      version: 7,
                      created: Time.parse("2023-01-01"),
                      updated: Time.parse("2023-01-01") },
                    { name: "pipeline-three",
                      version: 3,
                      created: Time.parse("2023-01-01"),
                      updated: Time.parse("2023-01-01") }] },
    )
  end

  def self.get_pipeline_state
    @codepipeline_client_stub.stub_data(
      :get_pipeline_state,
      { pipeline_name: "pipeline-one",
        pipeline_version: 6,
        stage_states: [{ stage_name: "stage-one",
                         inbound_transition_state: { enabled: true },
                         action_states: [{ action_name: "action-one",
                                           current_revision: { revision_id: "revision" },
                                           latest_execution: { action_execution_id: "action-id",
                                                               status: "Succeeded",
                                                               summary: '{"ProviderType":"GitHub","CommitMessage":"message"}',
                                                               last_status_change: Time.parse("2023-01-01"),
                                                               external_execution_id: "execution-id" },
                                           entity_url: "some-entity-url",
                                           revision_url: "some-revision-url" },
                                         { action_name: "action-two",
                                           current_revision: { revision_id: "revision" },
                                           latest_execution: { action_execution_id: "action-id",
                                                               status: "Succeeded",
                                                               summary: '{"ProviderType":"GitHub","CommitMessage":"message"}',
                                                               last_status_change: Time.parse("2023-01-01"),
                                                               external_execution_id: "execution-id" },
                                           entity_url: "some-entity-url",
                                           revision_url: "some-revision-url" }],
                         latest_execution: { pipeline_execution_id: "execution-id",
                                             status: "Succeeded" } },
                       { stage_name: "stage-two",
                         inbound_transition_state: { enabled: true },
                         action_states: [{ action_name: "action-one",
                                           latest_execution: { action_execution_id: "action-id",
                                                               status: "Succeeded",
                                                               last_status_change: Time.parse("2023-01-01"),
                                                               external_execution_id: "execution-id",
                                                               external_execution_url: "github-url" },
                                           entity_url: "some-entity-url" }],
                         latest_execution: { pipeline_execution_id: "execution-id",
                                             status: "Succeeded" } }],
        created: Time.parse("2023-01-01"),
        updated: Time.parse("2023-01-01") },
    )
  end
end
