require 'json'
require 'aws-sdk-codepipeline'
require 'logger'
require 'spec_helper'

require_relative '../invoke.rb'

describe Invoke do
  let(:codepipeline_client) { instance_double(Aws::CodePipeline::Client) }
  let(:pipeline_name) { 'PIPELINE_TO_INVOKE' }
  let(:container_image_uri) { 'CONTAINER_IMAGE_URI' }
  let(:event) do
    {
      'client_request_token' => 'some_token',
      'name' => pipeline_name,
      'variables' => [
        {
          'name' => 'container_image_uri',
          'value' => container_image_uri
        }
      ],
      'sourceRevisions' => [
        {
          'actionName' => 'some_action',
          'revisionType' => 'some_revision_type',
          'revisionValue' => 'some_revision_value'
        }
      ]
    }
  end

  before do
    allow(Aws::CodePipeline::Client).to receive(:new).and_return(codepipeline_client)
  end

  describe '#main' do
    it 'creates an Aws::CodePipeline::Client with the correct region' do
      expect(Aws::CodePipeline::Client).to receive(:new).with(region: 'eu-west-2').and_return(codepipeline_client)
      expect(codepipeline_client).to receive(:start_pipeline_execution)

      Invoke.main(event: event, context: double('context'))
    end

    it 'invokes the AWS CodePipeline API with correct parameters' do
        expected_params = {
          client_request_token: 'some_token',
          name: pipeline_name,
          source_revisions: [
            {
              action_name: 'some_action',
              revision_type: 'some_revision_type',
              revision_value: 'some_revision_value'
            }
          ],
          variables: [
            {
              name: 'container_image_uri',
              value: container_image_uri
            }
          ]
        }

        expect(codepipeline_client).to receive(:start_pipeline_execution).with(expected_params)

        Invoke.main(event: event, context: double('context'))
    end
  end
end